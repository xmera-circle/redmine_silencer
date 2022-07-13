# frozen_string_literal: true

# Load the normal Rails helper
require File.expand_path("#{File.dirname(__FILE__)}/../../../test/test_helper")
require File.expand_path("#{File.dirname(__FILE__)}/../app/services/update_notify_service")

module RedmineSilencer
  module PluginFixturesLoader
    def fixtures(*table_names)
      dir = "#{File.dirname __FILE__}/fixtures/"
      table_names.each do |table|
        ActiveRecord::FixtureSet.create_fixtures dir, table if File.exist? "#{dir}/#{table}.yml"
      end
      super table_names
    end
  end

  class TestCase < ActiveSupport::TestCase
    extend PluginFixturesLoader

    fixtures :users, :projects, :members, :member_roles,
             :roles, :trackers, :projects_trackers,
             :custom_fields, :custom_values, :custom_fields_trackers,
             :custom_fields_projects, :enumerations,
             :issue_statuses, :issue_categories, :issue_relations,
             :enumerations

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
end
