# frozen_string_literal: true

module RedmineSilencer
  ##
  # Uses controller hooks to modify issue notifications.
  #
  class IssueHooks < Redmine::Hook::Listener
    def controller_issues_new_before_save(context)
      params = context[:params] || {}
      service = UpdateNotifyService.new(suppress_mail: params[:suppress_mail],
                                        object: context[:issue])
      service.update_notify
    end

    def controller_issues_edit_before_save(context)
      params = context[:params] || {}
      service = UpdateNotifyService.new(suppress_mail: params[:suppress_mail],
                                        object: context[:journal])
      service.update_notify
    end

    def controller_issues_bulk_edit_before_save(context)
      params = context[:params] || {}
      service = UpdateNotifyService.new(suppress_mail: params[:suppress_mail],
                                        object: context[:issue]&.current_journal)
      service.update_notify
    end
  end
end
