module SharedSearch
  include Spinach::DSL

  step 'I search for "Perforce"' do
    fill_in 'search', with: 'Perforce'
    click_button 'Go'
  end
end
