require 'spec_helper'

describe QuestBack::Configuration do
  describe "#initialize" do
    it "has default wsdl URL" do
      expect(described_class.new.wsdl_url).to eq 'https://integration.questback.com/integration.svc?wsdl'
    end

    it "assigns incomming attributes" do
      config = described_class.new username: 'name', password: 'password', http_proxy: 'http://127.0.0.1/'

      expect(config.username).to eq 'name'
      expect(config.password).to eq 'password'
      expect(config.http_proxy).to eq 'http://127.0.0.1/'
    end
  end
end
