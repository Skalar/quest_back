require 'spec_helper'

describe QuestBack::Api, type: :request do
  let(:config) do
    QuestBack::Configuration.new(
      wsdl: path_to_fixture('quest_back.wsdl'),
      username: 'my-username',
      password: 'my-password'
    )
  end

  let(:expected_default_message) do
    {
      user_info: {
        'Username' => 'my-username',
        'Password' => 'my-password'
      }
    }
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
      context "success" do
        it "calls with correct message and response is successful" do
          savon.expects(:test_connection).with(message: expected_default_message).returns success_fixture_for 'test_connection'
          response = subject.test_connection
          expect(response).to be_successful
        end
      end

      context "failure" do
        it "raises error" do
          savon.expects(:test_connection).with(message: :any).returns failure_fixture_for 'test_connection'
          expect { subject.test_connection }.to raise_error Savon::SOAPFault
        end
      end
    end

    describe "#get_quests" do
      it "returns quests" do
        expected_message = expected_default_message.merge(
          paging_info: {'PageNo' => 0, 'PageSize' => 50},
          quest_filter: ''
        )

        savon.expects(:get_quests).with(message: expected_message).returns success_fixture_for 'get_quests'
        response = subject.get_quests
        expect(response).to be_successful
      end

      it "is possible to override default paging info" do
        expected_message = expected_default_message.merge(
          paging_info: {'PageNo' => 0, 'PageSize' => 1},
          quest_filter: ''
        )

        savon.expects(:get_quests).with(message: expected_message).returns success_fixture_for 'get_quests'
        response = subject.get_quests paging_info: {page_size: 1}
        expect(response).to be_successful
      end
    end

  end
end
