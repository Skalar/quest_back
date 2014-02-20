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
      it "makes call with expected arguments" do
        expected_message = expected_default_message.merge(
          paging_info: {'PageNo' => 0, 'PageSize' => 50},
          quest_filter: '',
          order!: QuestBack::Api::ORDER[:get_quests]
        )

        savon.expects(:get_quests).with(message: expected_message).returns success_fixture_for 'get_quests'
        response = subject.get_quests
        expect(response).to be_successful
      end

      it "is possible to override default paging info" do
        expected_message = expected_default_message.merge(
          paging_info: {'PageNo' => 0, 'PageSize' => 1},
          quest_filter: '',
          order!: QuestBack::Api::ORDER[:get_quests]
        )

        savon.expects(:get_quests).with(message: expected_message).returns success_fixture_for 'get_quests'
        response = subject.get_quests paging_info: {page_size: 1}
        expect(response).to be_successful
      end

      it "has expected results" do
        savon.expects(:get_quests).with(message: :any).returns success_fixture_for 'get_quests'
        response = subject.get_quests

        result = response.results.first

        expect(result[:quest_id]).to eq '4567668'
        expect(result[:security_lock]).to eq 'm0pI8orKJp'
        expect(result[:state]).to eq 'Active'
      end
    end

    describe "#get_language_list" do
      it "makes call with expected arguments" do
        savon.expects(:get_language_list).with(message: expected_default_message).returns success_fixture_for 'get_language_list'
        response = subject.get_language_list
        expect(response).to be_successful
      end

      it "has all known languages" do
        savon.expects(:get_language_list).with(message: :any).returns success_fixture_for 'get_language_list'
        response = subject.get_language_list

        expect(response.results.length).to eq 145
      end
    end

    describe "#add_email_invitees" do
      it "makes call with expected arguments" do
        expected_message = expected_default_message.merge(
          quest_info: {'QuestId' => 4567668, 'SecurityLock' => 'm0pI8orKJp'},
          emails: {'array:string' => ['inviso@skalar.no', 'th@skalar.no']},
          send_duplicate: false,
          order!: QuestBack::Api::ORDER[:add_email_invitees] - [:language_id]
        )


        savon.expects(:add_email_invitees).with(message: expected_message).returns success_fixture_for 'add_email_invitees'
        response = subject.add_email_invitees(
          quest_info: {
            quest_id: 4567668,
            security_lock: 'm0pI8orKJp'
          },
          emails: ['inviso@skalar.no', 'th@skalar.no']
        )
        expect(response).to be_successful
      end

      it "is possible to override defaults" do
        expected_message = expected_default_message.merge(
          quest_info: {'QuestId' => 4567668, 'SecurityLock' => 'm0pI8orKJp'},
          emails: {'array:string' => ['inviso@skalar.no', 'th@skalar.no']},
          send_duplicate: true,
          order!: QuestBack::Api::ORDER[:add_email_invitees] - [:language_id]
        )

        savon.expects(:add_email_invitees).with(message: expected_message).returns success_fixture_for 'add_email_invitees'
        response = subject.add_email_invitees(
          quest_info: {
            quest_id: 4567668,
            security_lock: 'm0pI8orKJp'
          },
          emails: ['inviso@skalar.no', 'th@skalar.no'],
          send_duplicate: true
        )
      end

      it "has expected result" do
        savon.expects(:add_email_invitees).with(message: :any).returns success_fixture_for 'add_email_invitees'
        response = subject.add_email_invitees(
          quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
          emails: ['inviso@skalar.no', 'th@skalar.no'],
        )

        expect(response.result).to eq 'Added 2 invitations to QuestId:4567668'
      end
    end
  end
end
