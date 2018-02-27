class Gamma::Command::Apply < Gamma::Command
  def initialize(opts)
    @database_settings = Gamma::DatabaseSettings.new(opts[:settings])
    # TODO: support postgres adapter
    @in_client = Gamma::DatabaseConnector::MysqlConnector.new(@database_settings.in_database)
    @out_client = Gamma::DatabaseConnector::MysqlConnector.new(@database_settings.out_database)
    @data_parser = Gamma::Parser::DataParser.new(opts[:data], @in_client, @out_client)
    @hook_root_dir = File.dirname(".")
    @syncdb = Gamma::SyncDatabase.new(opts[:sync_history] || "./history.json")
  end

  def execute
    tables = @data_parser.gamma_tables
    output_setting_warning(tables)

    tables.each do |t|
      logger.info("[#{t.sync_mode}] Sync Start #{t.table_name}".green)

      case t.sync_mode
      when "replace"
        Gamma::Importer::Replace.new(@in_client, @out_client, t).execute
      else
        logger.info("[#{t.sync_mode}] Sync Failed #{t.table_name}. Unknown Sync mode".red)
      end
    end
  end
end
