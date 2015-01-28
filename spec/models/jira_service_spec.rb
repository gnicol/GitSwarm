require 'spec_helper'

describe JiraService do
  describe "Associations" do
    it { should belong_to :project }
    it { should have_one :service_hook }
  end

  describe "Validations" do
    context "active" do
      before do
        subject.active = true
      end

      it { should validate_presence_of :project_url }
      it { should validate_presence_of :issues_url }
      it { should validate_presence_of :new_issue_url }
    end
  end

  describe 'description and title' do
    let(:project) { create(:project) }

    context 'when it is not set' do
      before do
        @service = project.create_jira_service(active: true)
      end

      after do
        @service.destroy!
      end

      it 'should be initialized' do
        expect(@service.title).to eq('JIRA')
        expect(@service.description).to eq("Jira issue tracker")
      end
    end

    context 'when it is set' do
      before do
        properties = { 'title' => 'Jira One', 'description' => 'Jira One issue tracker' }
        @service = project.create_jira_service(active: true, properties: properties)
      end

      after do
        @service.destroy!
      end

      it "should be correct" do
        expect(@service.title).to eq('Jira One')
        expect(@service.description).to eq('Jira One issue tracker')
      end
    end
  end

  describe 'project and issue urls' do
    let(:project) { create(:project) }

    context 'when gitlab.yml was initialized' do
      before do
        settings = { "jira" => {
          "title" => "Jira",
          "project_url" => "http://jira.sample/projects/project_a",
          "issues_url" => "http://jira.sample/issues/:id",
          "new_issue_url" => "http://jira.sample/projects/project_a/issues/new"
          }
        }
        Gitlab.config.stub(:issues_tracker).and_return(settings)
        @service = project.create_jira_service(active: true)
      end

      after do
        @service.destroy!
      end

      it 'should be prepopulated with the settings' do
        expect(@service.properties[:project_url]).to eq('http://jira.sample/projects/project_a')
        expect(@service.properties[:issues_url]).to eq("http://jira.sample/issues/:id")
        expect(@service.properties[:new_issue_url]).to eq("http://jira.sample/projects/project_a/issues/new")
      end
    end
  end
end
