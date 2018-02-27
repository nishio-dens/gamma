class Gamma::Importer
  def logger
    @_logger ||= Logger.new(STDOUT)
  end

  def set_foreign_key_off(client)
    client.client.query("SET FOREIGN_KEY_CHECKS=0")
  end

  def set_foreign_key_on(client)
    client.client.query("SET FOREIGN_KEY_CHECKS=1")
  end
end
