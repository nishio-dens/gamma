class Gamma::DatabaseSettings
  attr_reader :settings, :in_database, :out_database

  def initialize(yaml_path)
    @settings = YAML.load_file(yaml_path).with_indifferent_access
    @in_database = @settings[:in_database_config]
    @out_database = @settings[:out_database_config]
  end
end
