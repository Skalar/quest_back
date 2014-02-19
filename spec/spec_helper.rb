require 'bundler/setup'
require 'quest_back'
require "savon/mock/spec_helper"



module RequestHelpers
  def success_fixture_for(name)
    read_fixture "#{name}_success.xml"
  end

  def failure_fixture_for(name)
    read_fixture "#{name}_failure.xml"
  end

  def read_fixture(filename)
    File.read path_to_fixture(filename)
  end

  def path_to_fixture(filename)
    File.join(File.dirname(__FILE__), 'fixtures', filename)
  end
end



RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true

  # Mock savon request tests
  c.include Savon::SpecHelper, type: :request
  c.include RequestHelpers, type: :request
  c.before(type: :request) { savon.mock! }
  c.after(type: :request) { savon.unmock! }
end
