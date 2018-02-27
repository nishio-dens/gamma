class Gamma::Command::Apply < Gamma::Command
  def initialize(opts)
    @database_settings = Gamma::DatabaseSettings.new(opts[:settings])
    # TODO: support postgres adapter
    @in_client = Gamma::DatabaseConnector::MysqlConnector.new(@database_settings.in_database)
    @out_client = Gamma::DatabaseConnector::MysqlConnector.new(@database_settings.out_database)
    @data_parser = Gamma::Parser::DataParser.new(opts[:data], @in_client, @out_client)
  end

  def execute
    tables = @data_parser.gamma_tables
  end
end
