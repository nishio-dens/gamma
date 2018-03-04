class Gamma::Table
  attr_accessor :table_name, :in_exist, :out_exist, :in_exist_columns, :out_exist_columns
  attr_accessor :sync_mode, :delta_column
  attr_accessor :hooks

  def record_value(record)
    row_hooks = hooks.select { |h| h.hook_type.to_s == "row" }
    column_hooks = hooks.select { |h| h.hook_type.to_s == "column" }

    result = record
    result = row_hooks.reduce(record) { |h, rec| execute_row_hook(rec, h) } if row_hooks.present?
    result = column_hooks.reduce(record) { |h, rec| execute_row_hook(rec, h) } if column_hooks.present?

    result
  end

  private

  def execute_row_hook(hook, record)
    hook.execute_script(record)
  end

  def execute_column_hook(hook, record)
    record
  end
end
