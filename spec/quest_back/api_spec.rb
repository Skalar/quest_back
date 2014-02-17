require 'spec_helper'

describe QuestBack::Api, type: :request do
  let(:config) do
    QuestBack::Configuration.new(
      username: 'my-username',
      password: 'my-password'
    )
  end

  subject { described_class.new config: config }

  describe "#client" do
    it "is a savon client" do
      expect(subject.client).to be_a Savon::Client
    end
  end


  describe "operations" do
    describe "#test_connection" do
      # TODO
    end
  end
end
