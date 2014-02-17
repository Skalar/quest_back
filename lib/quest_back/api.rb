module QuestBack
  class Api
    def initialize(attributes = {})
      attributes = ActiveSupport::HashWithIndifferentAccess.new attributes

      @config = attributes[:config]
    end

    def client
      @client ||= Savon::Client.new(
        wsdl: config.wsdl_url
      )
    end

    def config
      @config || QuestBack.default_configuration || fail(QuestBack::Error, 'No configuration given or found on QuestBack.default_configuration.')
    end
  end
end
