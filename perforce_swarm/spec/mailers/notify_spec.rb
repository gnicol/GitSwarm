require 'spec_helper'
require 'email_spec'
require 'mailers/shared/notify'
require_relative 'shared/notify'

describe Notify do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include RepoHelpers

  include_context 'gitlab email notification'
  let(:example_site_path) { root_path }
  let(:user) { create(:user) }

  context 'for a project' do
    describe 'items that are assignable, the email' do
      let(:current_user) { create(:user, email: 'current@email.com') }
      let(:assignee) { create(:user, email: 'assignee@example.com') }
      let(:previous_assignee) { create(:user, name: 'Previous Assignee') }

      context 'for issues' do
        let(:issue) { create(:issue, author: current_user, assignee: assignee, project: project) }
        let(:issue_with_description) do
          create(:issue, author: current_user, assignee: assignee,
                         project: project, description: FFaker::Lorem.sentence
                )
        end

        describe 'that are new with a description' do
          subject { Notify.new_issue_email(issue_with_description.assignee_id, issue_with_description.id) }

          it 'contains the description', override: true do
            is_expected.to have_body_text(/#{CGI.escapeHTML(issue_with_description.description)}/)
          end
        end

        describe 'that have been reassigned' do
          subject { Notify.reassigned_issue_email(recipient.id, issue.id, previous_assignee.id, current_user.id) }

          it 'contains the name of the previous assignee', override: true do
            is_expected.to have_body_text(/#{CGI.escapeHTML(previous_assignee.name)}/)
          end

          it 'contains the name of the new assignee', override: true do
            is_expected.to have_body_text(/#{CGI.escapeHTML(assignee.name)}/)
          end
        end

        describe 'status changed' do
          let(:status) { 'closed' }
          subject { Notify.issue_status_changed_email(recipient.id, issue.id, status, current_user.id) }

          it 'contains the user name', override: true do
            is_expected.to have_body_text(/#{CGI.escapeHTML(current_user.name)}/i)
          end
        end
      end

      context 'for merge requests' do
        let(:merge_author) { create(:user) }
        let(:merge_request) do
          create(:merge_request, author: current_user, assignee: assignee,
                                 source_project: project, target_project: project
                )
        end
        let(:merge_request_with_description) do
          create(:merge_request, author: current_user, assignee: assignee,
                                 source_project: project, target_project: project,
                                 description: FFaker::Lorem.sentence
                )
        end

        describe 'that are new' do
          subject { Notify.new_merge_request_email(merge_request.assignee_id, merge_request.id) }

          context 'when enabled email_author_in_body' do
            it 'contains a link to note author', override: true do
              is_expected.to have_body_text(CGI.escapeHTML(merge_request.author_name))
            end
          end
        end

        describe 'that are new with a description' do
          subject do
            Notify.new_merge_request_email(merge_request_with_description.assignee_id,
                                           merge_request_with_description.id
                                          )
          end

          it 'contains the description', override: true do
            is_expected.to have_body_text(/#{CGI.escapeHTML(merge_request_with_description.description)}/)
          end
        end

        describe 'that are reassigned' do
          subject do
            Notify.reassigned_merge_request_email(recipient.id, merge_request.id,
                                                  previous_assignee.id, current_user.id
                                                 )
          end

          it 'contains the name of the previous assignee', override: true do
            is_expected.to have_body_text(/#{CGI.escapeHTML(previous_assignee.name)}/)
          end

          it 'contains the name of the new assignee', override: true do
            is_expected.to have_body_text(/#{CGI.escapeHTML(assignee.name)}/)
          end
        end

        describe 'status changed' do
          let(:status) { 'reopened' }
          subject { Notify.merge_request_status_email(recipient.id, merge_request.id, status, current_user.id) }

          it 'contains the user name', override: true do
            is_expected.to have_body_text(/#{CGI.escapeHTML(current_user.name)}/i)
          end
        end
      end
    end

    context 'items that are noteable, the email for a note' do
      let(:note_author) { create(:user, name: 'author_name') }
      let(:note) { create(:note, project: project, author: note_author) }

      shared_examples 'a note email' do
        it 'contains the message from the note', override: true do
          is_expected.to have_body_text(/#{CGI.escapeHTML(note.note)}/)
        end

        context 'when enabled email_author_in_body' do
          it 'contains a link to note author', override: true do
            is_expected.to have_body_text(CGI.parseHTML(note.author_name))
            is_expected.to have_body_text(/wrote\:/)
          end
        end
      end
    end
  end

  describe 'for new users, the email', override: true do
    let(:new_user) { create(:user, email: 'newguy@example.com', created_by_id: 1) }
    token = 'kETLwRaayvigPq_x3SNM'
    subject { Notify.new_user_email(new_user.id, token) }

    it_behaves_like 'an email sent from GitLab'
  end

  describe 'for users that signed up, the email', override: true do
    let(:new_user) { create(:user, email: 'newguy@example.com', password: 'securePassword') }
    subject { Notify.new_user_email(new_user.id) }

    it_behaves_like 'an email sent from GitLab'
  end

  describe 'user added ssh key', override: true do
    let(:key) { create(:personal_key) }
    subject { Notify.new_ssh_key_email(key.id) }

    it_behaves_like 'an email sent from GitLab'
  end

  context 'for a project' do
    describe 'project was moved', override: true do
      subject { Notify.project_was_moved_email(project.id, user.id, 'gitlab/gitlab') }

      it_behaves_like 'an email sent from GitLab'
    end

    describe 'project access changed', override: true do
      let(:project_member) do
        create(:project_member, project: project, user: user)
      end
      subject { Notify.project_access_granted_email(project_member.id) }

      it_behaves_like 'an email sent from GitLab'
    end
  end

  describe 'group access changed', override: true do
    let(:group) { create(:group) }
    let(:membership) { create(:group_member, group: group, user: user) }
    subject { Notify.group_access_granted_email(membership.id) }

    it_behaves_like 'an email sent from GitLab'
  end

  describe 'confirmation if email changed', override: true do
    let(:user) { create(:user, email: 'old-email@mail.com') }
    before do
      perform_enqueued_jobs do
        user.email = 'new-email@mail.com'
        user.save
      end
    end
    subject { ActionMailer::Base.deliveries.last }

    it_behaves_like 'an email sent from GitLab'
  end

  # EE only test
  if PerforceSwarm.ee?
    describe 'admin notification', override: true do
      let(:example_site_path) { root_path }
      let(:user) { create(:user) }

      subject { @email = Notify.send_admin_notification(user.id, 'Admin announcement', 'Text') }

      it 'is sent as the author' do
        sender = subject.header[:from].addrs[0]
        expect(sender.display_name).to eq('GitSwarm')
        expect(sender.address).to eq(gitlab_sender)
      end
    end
  end
end
