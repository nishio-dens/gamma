class Gamma::SyncDatabase
  def initialize(path)
    @sync_history_path = path
    @database = if File.exists?(@sync_history_path)
                  JSON.parse(open(@sync_history_path).read)
                else
                  {}
                end
  end

  def save
    open(@sync_history_path, "w") do |io|
      JSON.dump(@database, io)
    end
  end
end
