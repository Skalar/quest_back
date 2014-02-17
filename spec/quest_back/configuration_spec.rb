require 'spec_helper'

describe QuestBack::Configuration do
  describe "#initialize" do
    it "has default wsdl URL" do
      expect(described_class.new.wsdl_url).to eq 'https://integration.questback.com/integration.svc?wsdl'
    end

    it "assigns incomming attributes" do
      config = described_class.new username: 'name', password: 'password'

      expect(config.username).to eq 'name'
      expect(config.password).to eq 'password'
    end
  end
end
