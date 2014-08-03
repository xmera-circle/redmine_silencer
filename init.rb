require 'redmine'

Redmine::Plugin.register :redmine_silencer do
  name 'Redmine Silencer plugin'
  author 'Alex Shulgin'
  description 'A Redmine plugin to suppress email notifications (at will) when updating issues. (This is a fork by @commandprompt, @tofi86, @paginagmbh of the original plugin!)'
  version '0.3.1'
  url 'https://github.com/paginagmbh/redmine_silencer'
  author_url 'https://github.com/a1exsh/'
  requires_redmine :version_or_higher => '2.4.x'

  permission :suppress_mail_notifications, {}
end

prepare_block = Proc.new do
  Journal.send(:include, RedmineSilencer::JournalPatch)
end

if Rails.env.development?
  ActionDispatch::Reloader.to_prepare { prepare_block.call }
else
  prepare_block.call
end

require 'redmine_silencer/issue_hooks'
require 'redmine_silencer/view_hooks'
