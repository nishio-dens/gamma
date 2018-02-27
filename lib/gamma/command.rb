class Gamma::Command
  def gamma_tables(in_client, out_client, data_parser)
    database_exist_tables = database_tables(in_client, out_client, data_parser)
  end
end
