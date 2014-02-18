module QuestBack
  class Configuration
    API_DEFAULTS = {
      wsdl: 'https://integration.questback.com/integration.svc?wsdl',
      soap_namespace: 'https://integration.questback.com/2011/03',
      log_level: :debug
    }

    attr_accessor :http_proxy, :wsdl, :soap_namespace, :log_level, :username, :password

    def initialize(attributes = {})
      assign API_DEFAULTS
      assign attributes
    end

    def []=(name, value)
      public_send "#{name}=", value
    end

    def [](name)
      public_send name
    end



    private

    def assign(attributes)
      attributes.each_pair do |name, value|
        self[name] = value
      end
    end
  end
end
