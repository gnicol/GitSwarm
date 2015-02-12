require 'spec_helper'

describe Gitlab::ClosingIssueExtractor do
  let(:project) { create(:project) }
  let(:issue) { create(:issue, project: project) }
  let(:iid1) { issue.iid }

  describe :closed_by_message_in_project do
    context 'with a single reference' do
      it do
        message = "Awesome commit (Closes ##{iid1})"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Awesome commit (closes ##{iid1})"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Closed ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "closed ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Closing ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "closing ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Close ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "close ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Awesome commit (Fixes ##{iid1})"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Awesome commit (fixes ##{iid1})"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Fixed ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "fixed ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Fixing ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "fixing ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Fix ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "fix ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Awesome commit (Resolves ##{iid1})"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Awesome commit (resolves ##{iid1})"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Resolved ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "resolved ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Resolving ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "resolving ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "Resolve ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end

      it do
        message = "resolve ##{iid1}"
        subject.closed_by_message_in_project(message, project).should == [issue]
      end
    end

    context 'with multiple references' do
      let(:other_issue) { create(:issue, project: project) }
      let(:third_issue) { create(:issue, project: project) }
      let(:iid2) { other_issue.iid }
      let(:iid3) { third_issue.iid }

      it 'fetches issues in single line message' do
        message = "Closes ##{iid1} and fix ##{iid2}"

        subject.closed_by_message_in_project(message, project).
            should == [issue, other_issue]
      end

      it 'fetches comma-separated issues references in single line message' do
        message = "Closes ##{iid1}, closes ##{iid2}"

        subject.closed_by_message_in_project(message, project).
            should == [issue, other_issue]
      end

      it 'fetches comma-separated issues numbers in single line message' do
        message = "Closes ##{iid1}, ##{iid2} and ##{iid3}"

        subject.closed_by_message_in_project(message, project).
            should == [issue, other_issue, third_issue]
      end

      it 'fetches issues in multi-line message' do
        message = "Awesome commit (closes ##{iid1})\nAlso fixes ##{iid2}"

        subject.closed_by_message_in_project(message, project).
            should == [issue, other_issue]
      end

      it 'fetches issues in hybrid message' do
        message = "Awesome commit (closes ##{iid1})\n"\
                  "Also fixing issues ##{iid2}, ##{iid3} and #4"

        subject.closed_by_message_in_project(message, project).
            should == [issue, other_issue, third_issue]
      end
    end
  end
end
