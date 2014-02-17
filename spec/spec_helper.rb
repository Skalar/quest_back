require 'bundler/setup'
require 'quest_back'
require "savon/mock/spec_helper"

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true

  # Mock savon request tests
  c.include Savon::SpecHelper, type: :request
  c.before(type: :request) { savon.mock! }
  c.after(type: :request) { savon.unmock! }
end
