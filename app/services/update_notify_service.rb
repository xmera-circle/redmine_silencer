# frozen_string_literal: true

##
# Service object handling the update of the notification status
# for an object.
#
class UpdateNotifyService
  def initialize(**attrs)
    self.suppress_mail = attrs[:suppress_mail] || ''
    self.object = attrs[:object]
    self.current_user = User.current
  end

  def update_notify
    return object unless object.respond_to? :notify=
    return object unless suppress_mail?

    object.notify = false if current_user_allowed_to?
    object
  end

  private

  attr_accessor :suppress_mail, :object, :current_user

  def current_user_allowed_to?
    return false unless object.respond_to? :project

    current_user.allowed_to?(:suppress_mail_notifications, object.project)
  end

  def suppress_mail?
    suppress_mail == '1'
  end
end
