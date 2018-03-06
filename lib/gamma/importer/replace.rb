class Gamma::Importer::Replace < Gamma::Importer
  BATCH_SIZE = 1000

  def initialize(in_client, out_client, table, apply: false)
    @in_client = in_client
    @out_client = out_client
    @table = table
    @apply = apply
  end

  def execute
    set_foreign_key_off(@out_client)
    batch_sync
  ensure
    set_foreign_key_on(@out_client)
  end

  private

  def batch_sync
    columns = @table.in_exist_columns & @table.out_exist_columns
    primary_key = "id" # TODO: Fixme

    current_in_pid = 0
    while true do
      select_columns = columns.map { |c| "`#{c}`" }.join(",")
      break unless select_columns.present?

      in_query = "SELECT #{select_columns} FROM #{@table.table_name} WHERE #{primary_key} > #{current_in_pid} ORDER BY #{primary_key} ASC LIMIT #{BATCH_SIZE}"
      logger.info(in_query) if ENV["DEBUG"]
      in_records = @in_client.client.query(in_query).to_a

      break unless in_records.present?

      out_records = exist_records(select_columns, primary_key, in_records.map { |v| v[primary_key] })

      in_records.map { |ir| [ir, out_records.find { |v| ir[primary_key] == v[primary_key] }] }.each do |in_record, out_record|
        if out_record.present?
          update_out_record(in_record, out_record, primary_key)
        else
          insert_out_record(in_record)
        end
      end

      current_in_pid = in_records.last[primary_key]
    end
  rescue => e
    logger.error("Sync Error #{@table.table_name} \n #{e}\n #{e.backtrace.join("\n")}".red)
  end

  def exist_records(select_columns, primary_key, in_pids)
    return [] unless in_pids.present?

    query = "SELECT #{select_columns} FROM #{@table.table_name} WHERE #{primary_key} in (#{in_pids.join(",")})"
    @out_client.client.query(query).to_a
  end

  def update_out_record(in_record, out_record, primary_key)
    need_update = @table.delta_column.blank?
    need_update ||= @table.delta_column.present? && in_record[@table.delta_column] != out_record[@table.delta_column]
    if need_update
      record = @table.record_value(in_record)
      columns = (@table.in_exist_columns & @table.out_exist_columns).reject { |c| record[c].nil? }
      values = update_record_values(record, columns)

      query = <<-EOS
        UPDATE `#{@table.table_name}` SET #{values} WHERE #{primary_key} = #{record[primary_key]}
      EOS
      query = query.strip_heredoc
      logger.info(query) if ENV["DEBUG"]

      if @apply
        @out_client.client.query(query)
      else
        logger.info("DRYRUN: #{query}")
      end
    end
  end

  def insert_out_record(in_record)
    record = @table.record_value(in_record)
    columns = (@table.in_exist_columns & @table.out_exist_columns).reject { |c| record[c].nil? }
    select_columns = columns.map { |c| "`#{c}`" }.join(",")
    values = insert_record_values(record, columns)

    query = <<-EOS
      INSERT INTO #{@table.table_name}(#{select_columns}) VALUES (#{values})
    EOS
    query = query.strip_heredoc
    logger.info(query) if ENV["DEBUG"]

    if @apply
      @out_client.client.query(query)
    else
      logger.info("DRYRUN: #{query}")
    end
  end

  def insert_record_values(record, columns)
    r = record
    columns.map do |v|
      c = if r[v].is_a?(Time)
            r[v].strftime("%Y-%m-%d %H:%M:%S")
          else
            r[v]
          end
      "\"#{c.to_s.gsub('"', '\"')}\""
    end.join(",")
  end

  def update_record_values(record, columns)
    r = record
    columns.map do |v|
      c = if r[v].is_a?(Time)
            r[v].strftime("%Y-%m-%d %H:%M:%S")
          else
            r[v]
          end
      "#{v} = \"#{c}\""
    end.join(",")
  end
end
