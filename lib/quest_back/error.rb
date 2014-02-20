module QuestBack
  class Error < StandardError
    # Public: Raised when you ask response object for a single result when response contained multiple
    class MultipleResultsFound < self
    end
  end
end
