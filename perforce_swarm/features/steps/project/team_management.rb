require Rails.root.join('features', 'steps', 'project', 'team_management')
class Spinach::Features::ProjectTeamManagement < Spinach::FeatureSteps
  step 'I click link "New project member"' do
    click_link 'New project member'
  end

  step 'I attempt to add a non-existent user in the People field' do
    fill_in('s2id_autogen1', with: 'nonexistent-user')
    wait_for_ajax
  end

  step 'I should see "No matches found"' do
    all('ul.select2-results')[1].text.should have_content('No matches found')
  end

  step 'I attempt to add "*$%&@^!()" in the People field' do
    fill_in('s2id_autogen1', with: '*$%&@^!()')
    wait_for_ajax
  end

  step 'I click on the "Add users" button' do
    find(:css, 'input.btn.btn-create').trigger('click')
  end

  step 'I should still be on the "New project member(s)" page' do
    find(:css, '.page-title').should have_content('New project member(s)')
  end

  step 'I should see the "New project member(s)" page' do
    page.find('#new_project_member').should have_content('Choose people you want in the project')
  end

  step 'I click on the remove button' do
    find(:css, '.btn-remove').trigger('click')
  end
end
