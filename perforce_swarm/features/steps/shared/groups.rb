module SharedGroups
  include Spinach::DSL

  step 'group "QA" exists' do
    create(:group, name: 'QA')
  end

  step 'I click new group link' do
    click_link 'sidebar-groups-tab'
    click_link 'New group'
  end

  step 'submit form with new group "QAGroup" info' do
    fill_in 'group_name', with: 'QAGroup'
    fill_in 'group_description', with: 'QAGroup'
    click_button 'Create group'
  end

  step 'I should be redirected to group "QAGroup" page' do
    current_path.should == group_path(Group.last)
  end

  step 'I should see newly created group "QAGroup"' do
    page.should have_content 'QAGroup'
    page.should have_content 'QAGroup'
    page.should have_content 'Currently you are only seeing events from the'
  end
end
