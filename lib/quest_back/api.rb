module QuestBack
  class Api
    # This hash contains parts of request we can include in soap operation.
    # For instance call(:some_action, attributes, include_defaults: [:paging_info]) will
    # slice paging_info and include it in the request.
    DEFAULTS = {
      paging_info: {page_no: 0, page_size: 50},
      quest_filter: '',
      send_duplicate: false
    }

    # The order of the elements in the SOAP body is important for the SOAP API.
    # For operations with multiple arguments this hash gives savon the order of which
    # it should .. well, order the elements.
    ORDER = {
      get_quests: [:user_info, :paging_info, :quest_filter],
      add_email_invitees: [:user_info, :quest_info, :emails, :send_duplicate, :language_id]
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
      add_email_invitees: []
    }

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

    def add_email_invitees(attributes = {})
      call :add_email_invitees, attributes, include_defaults: [:send_duplicate]
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
          element_form_default: :qualified
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
          key = transform_keys ? key.to_s.camelcase : key
          value = case value
          when Hash
            transform_hash_for_quest_back value, true
          when Array
            value.all? { |v| v.is_a? String } ? {'arr:string' => value} : value
          else
            value
          end

          [key, value]
        end
      ]
    end
  end
end
