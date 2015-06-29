require Rails.root.join('features', 'steps', 'project', 'team_management')
class Spinach::Features::ProjectTeamManagement < Spinach::FeatureSteps
  step 'I click the button "Add members"' do
    click_button 'Add members'
  end

  step 'I attempt to add a non-existent user in the People field' do
    fill_in('s2id_autogen1', with: 'nonexistent-user')
    wait_for_ajax
  end

  step 'I should see "No matches found"' do
    all('ul.select2-results')[1].text.should have_content('No matches found')
  end

  step 'I attempt to add "*$%&^!()" in the People field' do
    fill_in('s2id_autogen1', with: '*$%&^!()')
    wait_for_ajax
  end

  step 'I click on the "Add users" button' do
    find(:css, 'input.btn.btn-create').trigger('click')
  end

  step 'I should still be on the "New project member(s)" form' do
    expect(page.find('#new_project_member').visible?).to be true
  end

  step 'I should see the "New project member(s)" form' do
    expect(page.find('#new_project_member').visible?).to be true
  end
end
