require 'spec_helper'

describe QuestBack::Api, type: :request do
  let(:config) do
    QuestBack::Configuration.new(
      wsdl_url: path_to_fixture('quest_back.wsdl'),
      username: 'my-username',
      password: 'my-password'
    )
  end

  subject { described_class.new config: config }

  describe "#client" do
    it "is a savon client" do
      expect(subject.client).to be_a Savon::Client
    end

    it "sets proxy building client" do
      config.http_proxy = 'http://127.0.0.1/'

      Savon::Client.should_receive(:new).
        with(hash_including(proxy: 'http://127.0.0.1/')).
        and_return :client

      expect(subject.client).to eq  :client
    end
  end


  describe "operations" do
    describe "#test_connection" do
      it "calls with correct message" do
        expected_message = {
          user_info: {
            'Username' => 'my-username',
            'Password' => 'my-password'
          }
        }

        savon.expects(:test_connection).with(message: expected_message).returns(read_fixture 'test_connection.xml')
        response = subject.test_connection
        expect(response).to be_successful
      end
    end
  end
end
