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


    # Public: Savon client.
    #
    # Savon client all API method calls will go through.
    def client
      @client ||= begin
        client_config = {wsdl: config.wsdl_url}
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
  end
end
