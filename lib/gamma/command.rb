class Gamma::Command
  def gamma_tables(in_client, out_client, data_parser)
    database_exist_tables = database_tables(in_client, out_client, data_parser)
  end

  def output_setting_warning(tables)
    dup_tables = tables.group_by { |t| t.table_name }.select { |k, v| v.size > 1 }.map(&:first)
    dup_tables.each do |tname|
      logger.warn("Table *#{tname}* settings are duplicated. Please review your data settings.".red)
    end
  end

  def logger
    @_logger ||= Logger.new(STDOUT)
  end
end
