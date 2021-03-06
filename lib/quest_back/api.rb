module QuestBack
  class Api
    # This hash contains parts of request we can include in soap operation.
    # For instance call(:some_action, attributes, include_defaults: [:paging_info]) will
    # slice paging_info and include it in the request.
    DEFAULTS = {
      paging_info: {page_no: 0, page_size: 50},
      quest_filter: '',
      sendduplicate: false,
      respondents_data: {
        delimiter: ';',
        order!: [:respondent_data_header, :respondent_data, :delimiter, :allow_duplicate, :add_as_invitee]
      }
    }

    # The order of the elements in the SOAP body is important for the SOAP API.
    # For operations with multiple arguments this hash gives savon the order of which
    # it should .. well, order the elements.
    ORDER = {
      get_quests: [:user_info, :paging_info, :quest_filter],
      add_email_invitees: [:user_info, :quest_info, :emails, :sendduplicate, :language_id],
      add_respondents_data: [:user_info, :quest_info, :respondents_data, :language_id],
      add_respondents_data_without_email_invitation: [:user_info, :quest_info, :respondents_data, :language_id],
      add_respondents_data_with_sms_invitation: [
        :user_info, :quest_info, :respondents_data, :language_id,
        :sms_from_number, :sms_from_text, :sms_message
      ]
    }

    # In order to provide a simple response.result and response.results interface
    # where the actual result we care about is returned we have to give knowledge to
    # where this result is found. As it turns out, get_quests returns it's quests within
    # quests/quest array, and at the same time get_quest_questions returns the questions
    # within simply it's root result element. No nestings there.. So, it seems a bit randon
    # and we need to have this configured. I though it would be put under quest_questions/quest_question,
    # but no such luck.
    RESULT_KEY_NESTINGS = {
      test_connection: [],
      get_quests: [:quests, :quest],
      get_language_list: [:language],
      add_email_invitees: [],
      add_respondents_data: [],
      add_respondents_data_without_email_invitation: [],
      add_respondents_data_with_sms_invitation: []
    }

    RESPONDENTS_HEADER_TYPE = {
      numeric: 1,
      text: 2
    }

    NAMESPACES = {
      'xmlns:array' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays',
      'xmlns:enum' => 'http://schemas.microsoft.com/2003/10/Serialization/Enums'
    }

    def self.respondent_data_header_type_for(type)
      RESPONDENTS_HEADER_TYPE.fetch(type.to_sym) do
        fail ArgumentError, "#{type.to_s.inspect} is an unkown respondent data header type."
      end
    end

    # Public: Creates a new API gateway object.
    #
    # Attributes
    #   config      - A QuestBack::Configuration object. May be nil if
    #                 QuestBack.default_configuration has been set.
    def initialize(attributes = {})
      attributes = ActiveSupport::HashWithIndifferentAccess.new attributes

      @config = attributes[:config]
    end







    # Public: Make a test connection call to QuestBack
    #
    # Returns QuestBack::Response
    def test_connection
      call :test_connection
    end

    # Public: Get quests
    #
    # attributes    -   Attributes sent to QuestBack
    #
    # Example
    #
    #   response = api.get_quests paging_info: {page_size: 2}  # Limits result to two
    #   response.results
    #   => [result, result]
    #
    # Returns QuestBack::Response
    def get_quests(attributes = {})
      call :get_quests, attributes, include_defaults: [:paging_info, :quest_filter]
    end

    # Public: Returns a list of languages from QuestBack.
    #
    #
    # Returns QuestBack::Response
    def get_language_list
      call :get_language_list
    end

    # Public: Invites a set of emails to a quest.
    #
    # attributes    -   Attributes sent to QuestBack
    #
    # Example
    #
    #   response = api.add_email_invitees(
    #     quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
    #     emails: ['inviso@skalar.no', 'th@skalar.no'],
    #     sendduplicate: true, # or false as default
    #     language_id: 123, # optional
    #   )
    #
    # Returns QuestBack::Response
    def add_email_invitees(attributes = {})
      call :add_email_invitees, attributes, include_defaults: [:sendduplicate]
    end

    # Public: Add respondent data to a quest - optionally send as invitee as well.
    #
    # attributes    -   Attributes sent to QuestBack
    #
    # QuestBack is doing a bit of CSV over XML here? As you need to serialize
    # respondent_data as a string with a delimiter ala CSV. The order of the
    # data must match the order of respondent_data_header. I guess simply using XML
    # and named elements was too easy? :-)
    #
    # Example
    #
    #   response = api.add_respondents_data(
    #     quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
    #     respondents_data: {
    #       respondent_data_header: {
    #         respondent_data_header: [
    #           {
    #             title: 'Epost',
    #             type: QuestBack::Api.respondent_data_header_type_for(:text),
    #             is_email_field: true,
    #             is_sms_field: false,
    #           },
    #           {
    #             title: 'Navn',
    #             type: QuestBack::Api.respondent_data_header_type_for(:text),
    #             is_email_field: false,
    #             is_sms_field: false,
    #           },
    #           {
    #             title: 'Alder',
    #             type: QuestBack::Api.respondent_data_header_type_for(:numeric),
    #             is_email_field: false,
    #             is_sms_field: false,
    #           },
    #         ]
    #       },
    #       respondent_data: ['th@skalar.no;Thorbjorn;32'], # According to QuestBack's doc you can only do one here
    #       allow_duplicate: true,
    #       add_as_invitee: true
    #     }
    #   )
    #
    # You may override respondent_data's delimiter in string too.
    #
    # Returns QuestBack::Response
    def add_respondents_data(attributes = {})
      call :add_respondents_data, attributes, include_defaults: [:respondents_data]
    end

    # Public: Add respondent data to a quest - optionally send as invitee as well.
    #         This will not send an email invitation through Questback's platform
    #
    # attributes    -   Attributes sent to QuestBack
    #
    # QuestBack is doing a bit of CSV over XML here? As you need to serialize
    # respondent_data as a string with a delimiter ala CSV. The order of the
    # data must match the order of respondent_data_header. I guess simply using XML
    # and named elements was too easy? :-)
    #
    # Example
    #
    #   response = api.add_respondents_data_without_email_invitation(
    #     quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
    #     respondents_data: {
    #       respondent_data_header: {
    #         respondent_data_header: [
    #           {
    #             title: 'Epost',
    #             type: QuestBack::Api.respondent_data_header_type_for(:text),
    #             is_email_field: true,
    #             is_sms_field: false,
    #           },
    #           {
    #             title: 'Navn',
    #             type: QuestBack::Api.respondent_data_header_type_for(:text),
    #             is_email_field: false,
    #             is_sms_field: false,
    #           },
    #           {
    #             title: 'Alder',
    #             type: QuestBack::Api.respondent_data_header_type_for(:numeric),
    #             is_email_field: false,
    #             is_sms_field: false,
    #           },
    #         ]
    #       },
    #       respondent_data: ['th@skalar.no;Thorbjorn;32'], # According to QuestBack's doc you can only do one here
    #       allow_duplicate: true,
    #       add_as_invitee: true
    #     }
    #   )
    #
    # You may override respondent_data's delimiter in string too.
    #
    # Returns QuestBack::Response
    def add_respondents_data_without_email_invitation(attributes = {})
      call :add_respondents_data_without_email_invitation, attributes, include_defaults: [:respondents_data]
    end

    # Public: Add respondent data to a quest with SMS invitation
    #
    # attributes    -   Attributes sent to QuestBack
    #
    #
    # Example
    #
    #   response = api.add_respondents_data_with_sms_invitation(
    #     quest_info: {quest_id: 4567668, security_lock: 'm0pI8orKJp'},
    #     respondents_data: {
    #       respondent_data_header: {
    #         respondent_data_header: [
    #           {
    #             title: 'Epost',
    #             type: QuestBack::Api.respondent_data_header_type_for(:text),
    #             is_email_field: true,
    #             is_sms_field: false,
    #           },
    #           {
    #             title: 'Phone',
    #             type: QuestBack::Api.respondent_data_header_type_for(:text),
    #             is_email_field: false,
    #             is_sms_field: true,
    #           }
    #         ]
    #       },
    #       # According to QuestBack's doc you can only do one respondent data,
    #       # even though it for sure is an array. Phone numbers must be given
    #       # on with country code first.
    #       respondent_data: ['th@skalar.no;4711223344'],
    #       allow_duplicate: true,
    #       add_as_invitee: true
    #     },
    #     sms_from_number: 11111111,
    #     sms_from_text: 'Inviso AS',
    #     sms_message: 'Hello - please join our quest!'
    #   )
    #
    # You may override respondent_data's delimiter in string too.
    #
    # Returns QuestBack::Response
    def add_respondents_data_with_sms_invitation(attributes = {})
      call :add_respondents_data_with_sms_invitation, attributes, include_defaults: [:respondents_data]
    end





    # Public: Savon client.
    #
    # Savon client all API method calls will go through.
    def client
      @client ||= begin
        client_config = {
          wsdl: config.wsdl,
          namespace: config.soap_namespace,
          log_level: config.log_level,
          element_form_default: :qualified,
          namespaces: NAMESPACES
        }

        client_config[:proxy] = config.http_proxy if config.http_proxy.present?

        Savon::Client.new client_config
      end
    end


    # Public: Configuration for the API.
    #
    # Returns a QuestBack::Configuration object
    def config
      @config || QuestBack.default_configuration || fail(QuestBack::Error, 'No configuration given or found on QuestBack.default_configuration.')
    end




    private

    def call(operation_name, attributes = {}, options = {})
      options[:operation_name] = operation_name

      options_to_response = {
        operation_name: options[:operation_name],
        result_key_nestings: RESULT_KEY_NESTINGS.fetch(operation_name) { fail KeyError, "You must configure RESULT_KEY_NESTINGS for #{operation_name}" }
      }

      savon_response = client.call operation_name, build_hash_for_savon_call(attributes, options)

      Response.new savon_response, options_to_response
    end


    # Private: Builds a hash for savon call - include user info and other defaults you ask it to
    #
    # attributes    -   A hash representing attributes the client sent to us which it expects us to send to QuestBack
    # options       -   A hash where we can send in options:
    #                     :include_defaults   -   Give an array with key names to slice from DEFAULTS and mix in with
    #                                             the rest of the attributes.
    #
    # Returns a merged hash for Savon client
    def build_hash_for_savon_call(attributes = {}, options = {})
      user_info = {user_info: {username: config.username, password: config.password}}
      message = user_info.merge attributes

      if default_keys = options[:include_defaults]
        message = DEFAULTS.slice(*Array.wrap(default_keys)).deep_merge message
      end

      if order = ORDER[options[:operation_name]]
        unkown_keys = attributes.keys - order

        if unkown_keys.any?
          fail ArgumentError, "Unkown attribute(s) given to #{options[:operation_name]}: #{unkown_keys.join(', ')}. Attributes' order is defined in #{self.class.name}::ORDER, but you sent in something we do not have."
        end

        message[:order!] = order & message.keys
      end

      {
        message: transform_hash_for_quest_back(message)
      }
    end


    # Private: Transforms given hash as how Savon needs it to build the correct SOAP body.
    #
    # Since QuestBack's API needs to have elements like this:
    #
    # <wsdl:TestConnection>
    #   <wsdl:userInfo>
    #     <wsdl:Username>
    #     ...
    #
    # We cannot simply use Savon's convert_request_keys_to config, as it translate all keys.
    # We need some keys camelcased (keys within nested hashes) and some lower_camelcased (keys in the outer most hash).
    #
    # Thus we map our inner attributes, for instance for userInfo to camelcase and keeps them
    # as strings so Savon will not manipulate them.
    #
    # I guess this helper method here is kinda not optimal, and we may have a simple class / struct
    # which can do this job for us, so the api class does not have multiple responsibilites. Oh well,
    # works for now.
    def transform_hash_for_quest_back(hash, transform_keys = false)
      Hash[
        hash.map do |key, value|
          if key == :order!
            # Key was :order! - it has special meaning: The symbols within it's array are used to
            # dictate order of elements. If transform_keys is false we are on "root keys". These are
            # keept as symbols and Savon does it's magic and we'll do nothing. If it is true it means that keys
            # on this level is put to camelcase and the values in the :order! array must match this.
            if transform_keys
              value = value.map { |v| v.to_s.camelcase }
            end
          else
            key = transform_keys ? key.to_s.camelcase : key

            # Oh my god this is quick, dirty and mega hackish!
            # Type element in the RespondentDataHeader must be in namespace enum.
            key = "enum:Type" if key == "Type"

            # In some cases we would like to transform values as well as the key
            value = case value
            when Hash
              # Keep on transforming recursively..
              transform_hash_for_quest_back value, true
            when Array
              if value.all? { |v| v.is_a? String }
                # Put it in a structure QuestBack likes..
                {'array:string' => value}
              elsif value.all? { |v| v.is_a? Hash }
                # Keep on transforming recursively..
                value.map { |hash| transform_hash_for_quest_back(hash, true) }
              end
            else
              # We don't know anything better - just let value fall through
              value
            end
          end

          [key, value]
        end
      ]
    end
  end
end
