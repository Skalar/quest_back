require "quest_back/version"

require "pathname"
require "active_support/all"
require "savon"


module QuestBack
  extend ActiveSupport::Autoload

  autoload :Configuration
  autoload :Error
  autoload :Response
  autoload :Api
  autoload :DebugObserver


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
  #
  # Injects a debug observer which hijacks requests so we don't send anything.
  # We'll pretty print the SOAP body for inspection.
  def self.debug!
    remove_debug!
    Savon.observers << DebugObserver.new
  end

  # :nodoc:
  #
  # Removes any debug observers.
  def self.remove_debug!
    Savon.observers.delete_if { |observer| observer.is_a? DebugObserver }
  end

  # :nodoc:
  def self.read_default_configuration_from_file(pathname)
    path = Pathname.new pathname
    path = Pathname.new [Dir.pwd, pathname].join('/') unless path.absolute?
    self.default_configuration = Configuration.new YAML.load_file(path)
  end
end
