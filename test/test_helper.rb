# frozen_string_literal: true

# Load the normal Rails helper
require File.expand_path("#{File.dirname(__FILE__)}/../../../test/test_helper")
require File.expand_path("#{File.dirname(__FILE__)}/../app/services/update_notify_service")

module RedmineSilencer
  module AuthenticateUser
    def log_user(login, password)
      login_page
      log_user_in(login, password)
      assert_equal login, User.find(user_session_id).login
    end

    module_function

    def login_page
      User.anonymous
      get '/login'
      assert_nil user_session_id
      assert_response :success
    end

    def user_session_id
      session[:user_id]
    end

    def log_user_in(login, password)
      post '/login', params: {
        username: login,
        password: password
      }
    end
  end

  class TestCase < ActiveSupport::TestCase
    fixtures :users, :projects, :members, :member_roles,
             :roles, :trackers, :projects_trackers,
             :custom_fields, :custom_values, :custom_fields_trackers,
             :custom_fields_projects, :enumerations,
             :issue_statuses, :issue_categories, :issue_relations,
             :enumerations, :watchers, :enabled_modules

    def setup
      @admin = users :users_001
      @jsmith = users :users_002 # projects 1, 2, 5
      @dlopper = users :users_003
      @manager = roles :roles_001
      @manager.add_permission! :suppress_mail_notifications
      @project = projects :projects_001
      @new_issue = Issue.generate(notify: true) # project 1
    end

    def teardown
      @new_issue = nil
    end
  end

  class ControllerTest < ActionDispatch::IntegrationTest
    include Redmine::I18n
    include AuthenticateUser

    fixtures :users, :projects, :members, :member_roles,
             :roles, :trackers, :projects_trackers,
             :custom_fields, :custom_values, :custom_fields_trackers,
             :custom_fields_projects, :enumerations,
             :issue_statuses, :issue_categories, :issue_relations,
             :enumerations, :watchers, :enabled_modules, :issues,
             :email_addresses, :user_preferences, :journals,
             :journal_details

    def setup
      @jsmith = users :users_002
      @project = projects :projects_001
      @manager = roles :roles_001
      @manager.add_permission! :suppress_mail_notifications
      @developer = roles :roles_002
      @developer.add_permission! :suppress_mail_notifications
      @issue = issues :issues_001
    end

    def teardown
      User.current = nil
    end
  end
end
