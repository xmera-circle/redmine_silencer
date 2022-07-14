# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../test_helper"
  
module RedmineSilencer
  class IssuesControllerTest < ControllerTest
  
    def test_create_with_suppress_mail_given
      ActionMailer::Base.deliveries.clear
      log_user('jsmith', 'jsmith')
      User.current = @jsmith
      with_settings :notified_events => %w(issue_added) do
        post project_issues_path(project_id: @project.id,
          :params => {
            :issue => {
              :tracker_id => 3,
              :status_id => 2,
              :subject => 'This is a new issue with watchers',
              :description => 'Watchers should not be notified!',
              :watcher_user_ids => ['2', '3']
            },
            :suppress_mail => '1'
          }
        )
      end
      issue = Issue.find_by_subject('This is a new issue with watchers')
      assert_not_nil issue
      assert_redirected_to :controller => 'issues', :action => 'show', :id => issue

      # Watchers not notified
      assert_equal 0, ActionMailer::Base.deliveries.size
    end

    def test_create_without_suppress_mail_given
      ActionMailer::Base.deliveries.clear
      log_user('jsmith', 'jsmith')
      User.current = @jsmith
      with_settings :notified_events => %w(issue_added) do
        post project_issues_path(project_id: @project.id,
          :params => {
            :issue => {
              :tracker_id => 3,
              :status_id => 2,
              :subject => 'This is another new issue with watchers',
              :description => 'Watchers should be notified!',
              :watcher_user_ids => ['2', '3']
            },
            :suppress_mail => '0'
          }
        )
      end
      issue = Issue.find_by_subject('This is another new issue with watchers')
      assert_not_nil issue
      assert_redirected_to :controller => 'issues', :action => 'show', :id => issue

      # Watchers notified
      assert_equal 2, ActionMailer::Base.deliveries.size
    end

    def test_update_with_suppress_mail_given
      ActionMailer::Base.deliveries.clear
      log_user('jsmith', 'jsmith')
      User.current = @jsmith
      with_settings :notified_events => %w(issue_updated) do
        patch issue_path(@issue,
          :params => {
            :issue => {
              :project_id => '2',
              :tracker_id => '1', # no change
              :priority_id => '6',
              :category_id => '3'
            },
            :suppress_mail => '1'
          }
        )
      end
      assert_redirected_to issue_path(@issue)
      issue = Issue.find(1)
      assert_equal 2, issue.project_id
      assert_equal 1, issue.tracker_id
      assert_equal 6, issue.priority_id
      assert_equal 3, issue.category_id

      # User notified
      assert_equal 0, ActionMailer::Base.deliveries.size
    end

    def test_update_without_suppress_mail_given
      ActionMailer::Base.deliveries.clear
      log_user('jsmith', 'jsmith')
      User.current = @jsmith
      with_settings :notified_events => %w(issue_updated) do
        patch issue_path(@issue,
          :params => {
            :issue => {
              :project_id => '2',
              :tracker_id => '1', # no change
              :priority_id => '6',
              :category_id => '3'
            },
            :suppress_mail => '0'
          }
        )
      end
      assert_redirected_to issue_path(@issue)
      issue = Issue.find(1)
      assert_equal 2, issue.project_id
      assert_equal 1, issue.tracker_id
      assert_equal 6, issue.priority_id
      assert_equal 3, issue.category_id

      # User notified
      assert_equal 1, ActionMailer::Base.deliveries.size
    end
  end

  def test_bulk_update_with_suppress_mail_given
    ActionMailer::Base.deliveries.clear
    log_user('jsmith', 'jsmith')
    User.current = @jsmith
    with_settings :notified_events => %w(issue_updated) do
      post bulk_update_issues_path(
        :params => {
          :ids => [1, 2],
          :notes => 'Bulk editing',
          :issue => {
            :priority_id => 7,
            :assigned_to_id => ''
          },
          :suppress_mail => '1'
        }
      )
      assert_response 302
      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  def test_bulk_update_without_suppress_mail_given
    ActionMailer::Base.deliveries.clear
    log_user('jsmith', 'jsmith')
    User.current = @jsmith
    with_settings :notified_events => %w(issue_updated) do
      post bulk_update_issues_path(
        :params => {
          :ids => [1, 2],
          :notes => 'Bulk editing',
          :issue => {
            :priority_id => 7,
            :assigned_to_id => ''
          },
          :suppress_mail => '0'
        }
      )
      assert_response 302
      # 4 emails for 2 members and 2 issues
      # 1 email for a watcher of issue #2
      assert_equal 5, ActionMailer::Base.deliveries.size
    end
  end
end
