gitswarm_user = User.create(
  email: 'gitswarm@example.com',
  name: 'GitSwarm System User',
  username: 'gitswarm',
  password_expires_at: nil,
  projects_limit: 0,
  can_create_group: false,
  force_random_password: true,
  confirmed_at: DateTime.now
)

gitswarm_user.generate_password
gitswarm_user.save!
