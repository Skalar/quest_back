module QuestBack
  # Public: Simple proxy object decorating Savon's response.
  #
  # Main motication for class is to have #result and #results as a common
  # interface to get to respons' result(s), with all outer response nesting
  # removed.
  #
  # At the moment you are still getting back simple hashes from both methods.
  class Response
    attr_reader :savon_response, :operation_name, :result_key_nestings

    delegate *Savon::Response.instance_methods(false), to: :savon_response

    def initialize(savon_response, options = {})
      @savon_response = savon_response
      @operation_name = options[:operation_name] or fail ArgumentError.new('Missing operation_name')
      @result_key_nestings = options[:result_key_nestings] or fail ArgumentError.new('Missing result key nestings')
    end

    def result
      extract_result.tap do |result|
        fail QuestBack::Error::MultipleResultsFound if result.is_a? Array
      end
    end

    def results
      Array.wrap extract_result
    end




    private

    def extract_result
      result_container = savon_response.body["#{operation_name}_response".to_sym]["#{operation_name}_result".to_sym]

      result = result_key_nestings.inject(result_container) do |result, key|
        result.fetch key do
          fail KeyError, "Expected #{result.inspect} to contain #{key_in_body}. Respons' result_key_nestings is wrong, or unexpected result from QuestBack."
        end
      end
    end
  end
end
