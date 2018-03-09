class Gamma::Hook
  attr_accessor :hook_type, :column_name, :script_path, :root_dir, :apply

  def execute_script(record)
    path = File.join(root_dir, script_path)
    fail "Hook Scripts Not Found. path: #{path}" unless File.exist?(path)

    result = record
    require File.join(root_dir, script_path)

    begin
      klass_name = "#{File.basename(path, ".*").camelize}"
      instance = klass_name.constantize.new
      case self.hook_type.to_s
      when "column"
        r = instance.execute(apply, column_name.to_s, record[column_name.to_s])
        record[column_name.to_s] = r
      when "row"
        record = instance.execute(apply, record)
      else
        fail "Error"
      end
    rescue => e
      raise "Invalid Hook Class #{klass_name}"
    end

    result
  end
end
