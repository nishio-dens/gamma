require 'mysql2'

class Gamma::DatabaseConnector::MysqlConnector < Gamma::DatabaseConnector
  DEFAULT_PORT = 3306

  attr_reader :config

  def initialize(config)
    @config = config
  end

  def client(database_name = @config[:database])
    @_client ||= Mysql2::Client.new(
      host: @config[:host],
      port: @config[:port] || DEFAULT_PORT,
      username: @config[:username],
      password: @config[:password] || "",
      database: database_name
    )
  end

  def schema_client
    @_schema_client ||= Mysql2::Client.new(
      host: @config[:host],
      port: @config[:port] || DEFAULT_PORT,
      username: @config[:username],
      password: @config[:password] || "",
      database: "information_schema"
    )
  end
end
