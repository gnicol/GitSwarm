class User
  DEFAULT_PASSWORD     = 'Passw0rd'.freeze
  DEFAULT_EMAIL_DOMAIN = '@test.com'.freeze

  attr_reader :name
  attr_reader :password
  attr_reader :email

  def initialize(name, password = nil, email = nil)
    @name = name
    @password = password || DEFAULT_PASSWORD
    @email = email || name + DEFAULT_EMAIL_DOMAIN
  end

  def to_s
    "User: #{@name}"
  end
end
