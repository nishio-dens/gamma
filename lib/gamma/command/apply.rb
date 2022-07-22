require 'parallel'

class Gamma::Command::Apply < Gamma::Command
  def initialize(opts)
    @database_settings = Gamma::DatabaseSettings.new(opts[:settings])
    # TODO: support postgres adapter
    @in_client = Gamma::DatabaseConnector::MysqlConnector.new(@database_settings.in_database)
    @out_client = Gamma::DatabaseConnector::MysqlConnector.new(@database_settings.out_database)
    @hook_root_dir = opts[:hook_dir] || '.'
    @syncdb = Gamma::SyncDatabase.new(opts[:sync_history] || './history.json')
    @data_parser = Gamma::Parser::DataParser.new(opts[:data], @hook_root_dir, @in_client, @out_client, apply: true)
  end

  def execute
    tables = @data_parser.gamma_tables
    output_setting_warning(tables)

    sync = lambda do |t|
      logger.info("[#{t.sync_mode}] Sync Start #{t.table_name}".green)

      case t.sync_mode
      when 'replace'
        Gamma::Importer::Replace.new(@in_client, @out_client, t, apply: true).execute
      when 'force_replace'
        Gamma::Importer::Replace.new(@in_client, @out_client, t, apply: true, ignore_error: true).execute
      else
        logger.info("[#{t.sync_mode}] Sync Failed #{t.table_name}. Unknown Sync mode".red)
      end
    end

    if ENV['PARALLEL_COUNT']
      Parallel.each(tables, in_processes: ENV['PARALLEL_COUNT'].to_i) { |t| sync.call(t) }
    else
      tables.each { |t| sync.call(t) }
    end
  end
end
