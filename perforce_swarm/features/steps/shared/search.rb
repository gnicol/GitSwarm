module SharedSearch
  include Spinach::DSL

  step 'I search for "Perforce"' do
    fill_in 'search', with: 'Perforce'
    click_button 'Go'
  end

  step 'I should see the Search page' do
    page.find(:css, '.btn-primary').should have_content('Search')
  end
end
