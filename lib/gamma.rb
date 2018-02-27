require "rubygems"
require "active_support"
require "active_support/core_ext"

if ENV["DEBUG"].present?
  require "pry"
end

require "gamma/version"
require "gamma/table"
require "gamma/hook"
require "gamma/database_settings"
require "gamma/database_connector"
require "gamma/database_connector/mysql_connector"
require "gamma/parser"
require "gamma/parser/data_parser"
require "gamma/importer"
require "gamma/importer/replace"
require "gamma/command"
require "gamma/command/apply"

module Gamma
end
