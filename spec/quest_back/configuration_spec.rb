require 'spec_helper'

describe QuestBack::Configuration do
  describe "#initialize" do
    it "assigns incomming attributes" do
      config = described_class.new username: 'name', password: 'password'

      expect(config.username).to eq 'name'
      expect(config.password).to eq 'password'
    end
  end
end
