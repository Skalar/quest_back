module QuestBack
  class Api
    # SOAP Operations we'll expose
    OPERATIONS = %w[
      test_connection
    ]


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


    # Public: Deep merges default attributes to send with the SOAP request.
    #
    # Returns a merged hash for Savon client
    def build_hash_for_savon_call(attributes = {})
      defaults = {
        user_info: {
          'Username' => config.username,
          'Password' => config.password
        }
      }

      {
        message: defaults.deep_merge(attributes)
      }
    end
  end
end
