require Rails.root.join('spec', 'support', 'login_helpers')

module LoginHelpers
  # Requires Javascript driver.
  def logout
    page.find(:css, 'header .profile-pic').click
    page.find(:css, 'header .logout').click
  end
end

# stub requests to updates.perforce.com for check for updates
WebMock.stub_request(:get, 'https://updates.perforce.com/static/GitSwarm/GitSwarm.json')
  .to_return(status: 200, body: '', headers: {})
