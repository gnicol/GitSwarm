require 'spec_helper'

describe Notify do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include RepoHelpers

  let(:gitlab_sender) { Gitlab.config.gitlab.email_from }
  let(:project) { create(:project) }
  let(:example_site_path) { root_path }
  let(:user) { create(:user) }

  shared_examples 'an email sent from GitLab' do
    it 'is sent from GitLab' do
      sender = subject.header[:from].addrs[0]
      expect(sender.display_name).to eq('GitSwarm')
      expect(sender.address).to eq(gitlab_sender)
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
      subject { Notify.project_was_moved_email(project.id, user.id) }

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
      user.email = 'new-email@mail.com'
      user.save
    end
    subject { ActionMailer::Base.deliveries.last }

    it_behaves_like 'an email sent from GitLab'
  end
end
