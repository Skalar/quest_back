module QuestBack
  # Public: Simple proxy object decorating Savon's response.
  #
  # Main motication for class is to have #result and a common
  # interface to get to respons' result.
  class Response
    attr_reader :savon_response, :operation_name

    delegate *Savon::Response.instance_methods(false), to: :savon_response

    def initialize(savon_response, operation_name)
      @savon_response = savon_response
      @operation_name = operation_name
    end

    def result
      savon_response.body["#{operaiton_name_in_body}Response"]["#{operaiton_name_in_body}Result"]
    end

    private

    def operaiton_name_in_body
      operation_name.to_s.camelcase
    end
  end
end
