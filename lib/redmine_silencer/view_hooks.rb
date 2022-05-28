module RedmineSilencer
  class ViewHooks < Redmine::Hook::ViewListener
    def view_issues_form_details_bottom(context = {})
      return unless /^(Issues)/.match?(context[:controller].class.name)
      return unless context[:controller].action_name == 'new'

      context[:controller].send :render_to_string, {
        partial: 'hooks/silencer_suppress_mail',
        locals: context
      }
    end

    render_on :view_issues_edit_notes_bottom,
      :partial => 'hooks/silencer_suppress_mail'

    render_on :view_issues_bulk_edit_details_bottom,
      :partial => 'hooks/silencer_suppress_mail'
  end
end
