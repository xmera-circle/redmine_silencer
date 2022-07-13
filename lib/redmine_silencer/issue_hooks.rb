# frozen_string_literal: true

module RedmineSilencer
  ##
  # Uses controller hooks to modify issue notifications.
  #
  class IssueHooks < Redmine::Hook::Listener
    def controller_issues_new_before_save(context)
      update_notify(context[:params], context[:issue])
    end

    def controller_issues_edit_before_save(context)
      update_notify(context[:params], context[:journal])
    end

    def controller_issues_bulk_edit_before_save(context)
      update_notify(context[:params], context[:issue]&.current_journal)
    end

    private

    def update_notify(params, object)
      return unless object && params && params[:suppress_mail] == '1'

      object.notify = false if User.current.allowed_to?(:suppress_mail_notifications, object.project)
    end
  end
end
