Rails.application.routes.draw do
  devise_scope :user do
    get 'user/recent_projects' => 'application#load_user_recent_projects'
  end
end
