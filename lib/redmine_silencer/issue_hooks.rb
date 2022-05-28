# frozen_string_literal: true

module RedmineSilencer
  ##
  # Uses controller hooks to modify issue notifications.
  #
  class IssueHooks < Redmine::Hook::Listener
    def controller_issues_new_before_save(context)
      update_journal_notify(context[:params], context[:journal])
    end

    def controller_issues_edit_before_save(context)
      update_journal_notify(context[:params], context[:journal])
    end

    def controller_issues_bulk_edit_before_save(context)
      update_journal_notify(context[:params], context[:issue].current_journal)
    end

    private

    def update_journal_notify(params, journal)
      return unless journal && params && params[:suppress_mail] == '1'

      journal.notify = false if User.current.allowed_to?(:suppress_mail_notifications, journal.project)
    end
  end
end
