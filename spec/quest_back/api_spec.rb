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

      expect(Savon::Client).to receive(:new).
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
          sendduplicate: false,
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
          sendduplicate: true,
          order!: QuestBack::Api::ORDER[:add_email_invitees] - [:language_id]
        )

        savon.expects(:add_email_invitees).with(message: expected_message).returns success_fixture_for 'add_email_invitees'
        response = subject.add_email_invitees(
          quest_info: {
            quest_id: 4567668,
            security_lock: 'm0pI8orKJp'
          },
          emails: ['inviso@skalar.no', 'th@skalar.no'],
          sendduplicate: true
        )
      end

      it "fails if you give it keys which are not known" do
        expect { subject.add_email_invitees(foo: 'bar') }.to raise_error ArgumentError
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


    describe "#add_respondents_data" do
      it "makes call with expected arguments" do
        expected_message = expected_default_message.merge(
          quest_info: {'QuestId' => 4567668, 'SecurityLock' => 'm0pI8orKJp'},
          respondents_data: {
            'RespondentDataHeader' => {
              'RespondentDataHeader' => [
                {
                  'Title' => 'Epost',
                  'enum:Type' => 2,
                  'IsEmailField' => true,
                  'IsSmsField' => false
                },
                {
                  'Title' => 'Mobil',
                  'enum:Type' => 2,
                  'IsEmailField' => false,
                  'IsSmsField' => true
                },
                {
                  'Title' => 'Navn',
                  'enum:Type' => 2,
                  'IsEmailField' => false,
                  'IsSmsField' => false
                },
                {
                  'Title' => 'Alder',
                  'enum:Type' => 1,
                  'IsEmailField' => false,
                  'IsSmsField' => false
                }
              ]
            },
            'RespondentData' => {'array:string' => ['th@skalar.no;404 40 404;Thorbjorn;32']},
            'Delimiter' => ';',
            'AllowDuplicate' => true,
            'AddAsInvitee' => true,
            order!: ["RespondentDataHeader", "RespondentData", "Delimiter", "AllowDuplicate", "AddAsInvitee"]
          } ,
          order!: QuestBack::Api::ORDER[:add_respondents_data] - [:language_id]
        )


        savon.expects(:add_respondents_data).with(message: expected_message).returns success_fixture_for 'add_respondents_data'
        response = subject.add_respondents_data(
          quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
          respondents_data: {
            respondent_data_header: {
              respondent_data_header: [
                {
                  title: 'Epost',
                  type: QuestBack::Api.respondent_data_header_type_for(:text),
                  is_email_field: true,
                  is_sms_field: false,
                },
                {
                  title: 'Mobil',
                  type: QuestBack::Api.respondent_data_header_type_for(:text),
                  is_email_field: false,
                  is_sms_field: true,
                },
                {
                  title: 'Navn',
                  type: QuestBack::Api.respondent_data_header_type_for(:text),
                  is_email_field: false,
                  is_sms_field: false,
                },
                {
                  title: 'Alder',
                  type: QuestBack::Api.respondent_data_header_type_for(:numeric),
                  is_email_field: false,
                  is_sms_field: false,
                },
              ]
            },
            respondent_data: ['th@skalar.no;404 40 404;Thorbjorn;32'],
            allow_duplicate: true,
            add_as_invitee: true
          }
        )

        expect(response).to be_successful
      end
    end

    describe "#add_respondents_data_without_email_invitation" do
      it "makes call with expected arguments" do
        expected_message = expected_default_message.merge(
          quest_info: {'QuestId' => 4567668, 'SecurityLock' => 'm0pI8orKJp'},
          respondents_data: {
            'RespondentDataHeader' => {
              'RespondentDataHeader' => [
                {
                  'Title' => 'Epost',
                  'enum:Type' => 2,
                  'IsEmailField' => true,
                  'IsSmsField' => false
                },
                {
                  'Title' => 'Mobil',
                  'enum:Type' => 2,
                  'IsEmailField' => false,
                  'IsSmsField' => true
                },
                {
                  'Title' => 'Navn',
                  'enum:Type' => 2,
                  'IsEmailField' => false,
                  'IsSmsField' => false
                },
                {
                  'Title' => 'Alder',
                  'enum:Type' => 1,
                  'IsEmailField' => false,
                  'IsSmsField' => false
                }
              ]
            },
            'RespondentData' => {'array:string' => ['th@skalar.no;404 40 404;Thorbjorn;32']},
            'Delimiter' => ';',
            'AllowDuplicate' => true,
            'AddAsInvitee' => true,
            order!: ["RespondentDataHeader", "RespondentData", "Delimiter", "AllowDuplicate", "AddAsInvitee"]
          },
          order!: QuestBack::Api::ORDER[:add_respondents_data_without_email_invitation] - [:language_id]
        )

        savon.expects(:add_respondents_data_without_email_invitation).with(message: expected_message).returns success_fixture_for 'add_respondents_data_without_email_invitation'
        response = subject.add_respondents_data_without_email_invitation(
          quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
          respondents_data: {
            respondent_data_header: {
              respondent_data_header: [
                {
                  title: 'Epost',
                  type: QuestBack::Api.respondent_data_header_type_for(:text),
                  is_email_field: true,
                  is_sms_field: false,
                },
                {
                  title: 'Mobil',
                  type: QuestBack::Api.respondent_data_header_type_for(:text),
                  is_email_field: false,
                  is_sms_field: true,
                },
                {
                  title: 'Navn',
                  type: QuestBack::Api.respondent_data_header_type_for(:text),
                  is_email_field: false,
                  is_sms_field: false,
                },
                {
                  title: 'Alder',
                  type: QuestBack::Api.respondent_data_header_type_for(:numeric),
                  is_email_field: false,
                  is_sms_field: false,
                },
              ]
            },
            respondent_data: ['th@skalar.no;404 40 404;Thorbjorn;32'],
            allow_duplicate: true,
            add_as_invitee: true
          }
        )

        expect(response).to be_successful
      end
    end

    describe "#add_respondents_data_with_sms_invitation" do
      it "makes call with expected arguments" do
        expected_message = expected_default_message.merge(
          quest_info: {'QuestId' => 4567668, 'SecurityLock' => 'm0pI8orKJp'},
          respondents_data: {
            'RespondentDataHeader' => {
              'RespondentDataHeader' => [
                {
                  'Title' => 'Epost',
                  'enum:Type' => 2,
                  'IsEmailField' => true,
                  'IsSmsField' => false
                },
                {
                  'Title' => 'Mobil',
                  'enum:Type' => 2,
                  'IsEmailField' => false,
                  'IsSmsField' => true
                }
              ]
            },
            'RespondentData' => {'array:string' => ['th@skalar.no;404 40 404']},
            'Delimiter' => ';',
            'AllowDuplicate' => true,
            'AddAsInvitee' => true,
            order!: ["RespondentDataHeader", "RespondentData", "Delimiter", "AllowDuplicate", "AddAsInvitee"]
          },
          sms_from_number: 11111111,
          sms_from_text: 'Inviso AS',
          sms_message: 'Hello - please join our quest!',
          order!: QuestBack::Api::ORDER[:add_respondents_data_with_sms_invitation] - [:language_id]
        )


        savon.expects(:add_respondents_data_with_sms_invitation)
          .with(message: expected_message)
          .returns success_fixture_for 'add_respondents_data_with_sms_invitation'


        response = subject.add_respondents_data_with_sms_invitation(
          quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
          respondents_data: {
            respondent_data_header: {
              respondent_data_header: [
                {
                  title: 'Epost',
                  type: QuestBack::Api.respondent_data_header_type_for(:text),
                  is_email_field: true,
                  is_sms_field: false,
                },
                {
                  title: 'Mobil',
                  type: QuestBack::Api.respondent_data_header_type_for(:text),
                  is_email_field: false,
                  is_sms_field: true,
                }
              ]
            },
            respondent_data: ['th@skalar.no;404 40 404'],
            allow_duplicate: true,
            add_as_invitee: true
          },
          sms_from_number: 11111111,
          sms_from_text: 'Inviso AS',
          sms_message: 'Hello - please join our quest!'
        )

        expect(response).to be_successful
      end

      it "fails with soap error when phone number isn't parsable" do
        savon.expects(:add_respondents_data_with_sms_invitation)
          .with(message: :any)
          .returns failure_fixture_for 'add_respondents_data_with_sms_invitation'

        expect {
          subject.add_respondents_data_with_sms_invitation
        }.to raise_error Savon::SOAPFault
      end
    end
  end
end
