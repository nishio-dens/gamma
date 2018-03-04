class Gamma::Parser::DataParser < Gamma::Parser
  DEFAULT_SYNC_MODE = "replace"

  def initialize(data_yaml_path, hook_root_dir, in_client, out_client, apply: false)
    @data_settings = YAML.load_file(data_yaml_path).map(&:with_indifferent_access)
    @hook_root_dir = hook_root_dir
    @in_client = in_client
    @out_client = out_client
    @apply = apply
  end

  def gamma_tables
    exist_tables = database_exist_tables
    @data_settings.map do |d|
      parse_data_settings(d[:data], exist_tables)
    end.flatten
  end

  def parse_data_settings(data, exist_tables)
    tables = if Array(data[:table]).join == "*"
               without = Array(data[:table_without]) || []
               exist_tables.reject { |v| without.include?(v.table_name) }
             else
               Array(data[:table]).map do |table_name|
                 exist_tables.find { |t| t.table_name == table_name }
               end.compact
             end
    tables = tables.map do |t|
      t.sync_mode = data[:mode].presence || DEFAULT_SYNC_MODE
      t.delta_column = data[:delta_column]
      t.hooks = data[:hooks].present? ? parse_hooks(data[:hooks], t) : []

      t
    end
    tables
  end

  private

  def database_exist_tables
    in_tables = select_table_definitions(@in_client)
    out_tables = select_table_definitions(@out_client)

    (in_tables + out_tables).uniq.map do |table|
      t = Gamma::Table.new
      t.table_name = table
      t.in_exist = in_tables.include?(table)
      t.out_exist = out_tables.include?(table)
      t.in_exist_columns = select_column_definitions(@in_client, table)
      t.out_exist_columns = select_column_definitions(@out_client, table)
      t
    end
  end

  def select_table_definitions(client)
    query = <<-EOS
      SELECT
        *
      FROM
        TABLES
      INNER JOIN
        COLLATION_CHARACTER_SET_APPLICABILITY CCSA
      ON
        TABLES.TABLE_COLLATION = CCSA.COLLATION_NAME
      WHERE
        TABLE_SCHEMA = '#{client.schema_client.escape(client.config[:database])}'
      ORDER BY
        TABLE_NAME
    EOS
    client.schema_client.query(query.strip_heredoc).to_a.map { |v| v["TABLE_NAME"] }
  end

  def select_column_definitions(client, table_name)
    query = <<-EOS
      SELECT
        *
      FROM
        COLUMNS
      WHERE
        TABLE_SCHEMA = '#{client.schema_client.escape(client.config[:database])}'
        AND TABLE_NAME = '#{client.schema_client.escape(table_name)}'
      ORDER BY
        TABLE_NAME, ORDINAL_POSITION
    EOS
    client.schema_client.query(query.strip_heredoc).to_a.map { |v| v["COLUMN_NAME"] }
  end

  def parse_hooks(hooks, table)
    hooks = hooks.is_a?(Array) ? hooks : [hooks]
    hooks.map do |hook|
      type = if hook[:row].present?
               :row
             elsif hook[:column].present?
               :column
             end

      if type == :row
        options = hook[:row]
        fail "Required scripts arguments. table: #{table.table_name}, hook_type: #{type}" unless options[:scripts].present?

        Array(options[:scripts]).map do |script|
          h = Gamma::Hook.new
          h.hook_type = :row
          h.column_name = nil
          h.script_path = script
          h.root_dir = @hook_root_dir
          h.apply = @apply
          h
        end
      elsif type == :column
        options = hook[:column]
        fail "Required column name arguments. table: #{table.table_name}, hook_type: #{type}" unless options[:name].present?
        fail "Required scripts arguments. table: #{table.table_name}, hook_type: #{type}" unless options[:scripts].present?

        column_names = Array(options[:name])
        scripts = Array(options[:scripts])
        column_names.product(scripts).map do |column_name, script|
          h = Gamma::Hook.new
          h.hook_type = :column
          h.column_name = column_name
          h.script_path = script
          h.root_dir = @hook_root_dir
          h.apply = @apply
          h
        end
      else
        fail "Unknown Hook Type"
      end
    end.flatten.compact
  end
end
