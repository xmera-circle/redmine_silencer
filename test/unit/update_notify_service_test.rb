# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../test_helper"

module RedmineSilencer
  class UpdateNotifyServiceTest < TestCase
    def test_update_notify_for_issue_create_if_admin
      User.current = @admin
      with_settings :notified_events => %w(issue_added) do
        service = UpdateNotifyService.new(suppress_mail: '1', object: @new_issue)
        response = service.update_notify
        assert_not response.notify?
      end
    end

    def test_update_notify_for_issue_create_if_user_allowed
      User.current = @jsmith
      with_settings :notified_events => %w(issue_added) do
        service = UpdateNotifyService.new(suppress_mail: '1', object: @new_issue)
        response = service.update_notify
        assert_not response.notify?
      end
    end

    def test_update_notify_for_issue_create_if_user_not_allowed
      User.current = @dlopper
      with_settings :notified_events => %w(issue_added) do
        service = UpdateNotifyService.new(suppress_mail: '1', object: @new_issue)
        response = service.update_notify
        assert response.notify?
      end
    end

    def test_update_notify_without_suppress_mail_given
      User.current = @jsmith
      with_settings :notified_events => %w(issue_added) do
        service = UpdateNotifyService.new(suppress_mail: nil, object: @new_issue)
        response = service.update_notify
        assert response.nil?
      end
    end
    
    def test_update_notify_with_wrong_object_given
      User.current = @jsmith
      with_settings :notified_events => %w(issue_added) do
        service = UpdateNotifyService.new(suppress_mail: nil, object: Object.new)
        response = service.update_notify
        assert response.nil?
      end
    end
  end
end
