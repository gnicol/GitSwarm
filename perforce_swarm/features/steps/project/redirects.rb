require Rails.root.join('features', 'steps', 'project', 'redirects')

class Spinach::Features::ProjectRedirects < Spinach::FeatureSteps
  step 'Authenticate' do
    admin = create(:admin)
    @project = Project.find_by(name: 'Community')
    fill_in 'user_login', with: admin.email
    fill_in 'user_password', with: admin.password
    click_button 'Log in'
    Thread.current[:current_user] = admin
  end

  step 'I get redirected to signin page where I sign in' do
    admin = create(:admin)
    @project = Project.find_by(name: 'Enterprise')
    fill_in 'user_login', with: admin.email
    fill_in 'user_password', with: admin.password
    click_button 'Log in'
    Thread.current[:current_user] = admin
  end
end
