module QuestBack
  class Configuration
    API_DEFAULTS = {
    }

    attr_accessor :username, :password

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
