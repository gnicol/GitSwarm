module SharedSearch
  include Spinach::DSL

  step 'I search for "Perforce"' do
    fill_in 'search', with: 'Perforce'
    find(:css, 'form.navbar-form button').trigger('click')
  end

  step 'I should see the Search page' do
    page.find(:css, '.btn-search').should have_content('Search')
  end
end
