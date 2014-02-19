module QuestBack
  class Api
    DEFAULTS = {
      paging_info: {page_no: 0, page_size: 50},
      quest_filter: ''
    }

    ORDER = {
      get_quests: [:user_info, :paging_info, :quest_filter]
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



    def test_connection
      client.call :test_connection, build_hash_for_savon_call
    end

    def get_quests(attributes = {})
      client.call :get_quests, build_hash_for_savon_call(attributes, operation_name: :get_quests, include_defaults: [:paging_info, :quest_filter])
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

      if operation_name = options[:operation_name]
        if order = ORDER[operation_name]
          message[:order!] = order
        end
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
            value.all? { |v| v.is_a? String } ? {string: value} : value
          else
            value
          end

          [key, value]
        end
      ]
    end
  end
end
