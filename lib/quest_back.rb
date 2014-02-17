require "quest_back/version"

require "pathname"
require "active_support/all"

module QuestBack
  extend ActiveSupport::Autoload

  autoload :Configuration
  autoload :Client


  # Public: Default configuration is read from here.
  #
  # Returns a Configuration object
  mattr_accessor :default_configuration





  # :nodoc:
  #
  # Read config from file, just makes it easy for me to spin up
  # a console, read API credentials and get going
  def self.conf!
    read_default_configuration_from_file 'config.yml'
  end

  # :nodoc:
  def self.read_default_configuration_from_file(pathname)
    path = Pathname.new pathname
    path = Pathname.new [Dir.pwd, pathname].join('/') unless path.absolute?
    self.default_configuration = Configuration.new YAML.load_file(path)
  end
end
