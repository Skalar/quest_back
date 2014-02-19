module QuestBack
  class Api
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


    # Private: Deep merges default attributes to send with the SOAP request.
    #
    # Returns a merged hash for Savon client
    def build_hash_for_savon_call(attributes = {})
      defaults = {user_info: {username: config.username, password: config.password}}
      message = defaults.merge attributes

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
          value = value.is_a?(Hash) ? transform_hash_for_quest_back(value, true) : value

          [key, value]
        end
      ]
    end
  end
end
