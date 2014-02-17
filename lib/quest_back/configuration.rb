module QuestBack
  class Configuration
    API_DEFAULTS = {
      wsdl_url: 'https://integration.questback.com/integration.svc?wsdl'
    }

    attr_accessor :wsdl_url, :username, :password

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
