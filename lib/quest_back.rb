require "quest_back/version"

require "active_support/all"

module QuestBack
  extend ActiveSupport::Autoload

  autoload :Configuration
  autoload :Client
end
