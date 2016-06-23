# Custom password length limits

If you want to enforce longer user passwords you can create an extra Devise
initializer with the steps below.

If you do not use the `devise_password_length.rb` initializer the password
length is set to a minimum of 8 characters in
`config/initializers/devise.rb`.

```bash
# package installations
cd /opt/gitswarm/embedded/service/gitlab-rails/config/initializers
sudo cp -a devise_password_length.rb.example devise_password_length.rb
sudo editor devise_password_length.rb   # inspect and edit the new password length limits

# source installations
cd /home/git/gitlab/config/initializers
sudo -u git -H cp devise_password_length.rb.example devise_password_length.rb
sudo -u git -H editor devise_password_length.rb   # inspect and edit the new password length limits
```
