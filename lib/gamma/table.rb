class Gamma::Table
  attr_accessor :table_name, :in_exist, :out_exist, :in_exist_columns, :out_exist_columns
  attr_accessor :sync_mode, :delta_column
  attr_accessor :hooks
end
