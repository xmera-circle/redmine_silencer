# frozen_string_literal: true

module RedmineSilencer
  ##
  # Overrides Journal instance methods
  #
  module JournalPatch
    def notify?
      @notify
    end

    def notify=(arg)
      @notify = !!arg
    end
  end
end
