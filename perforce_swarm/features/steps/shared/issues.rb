module SharedIssues
  include Spinach::DSL

  step 'I click link "New Issue"' do
    click_link 'New Issue'
  end

  step 'I submit new issue "New Issue"' do
    fill_in 'issue_title', with: 'New Issue'
    click_button 'Submit new issue'
  end
end
