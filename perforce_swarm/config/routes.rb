Rails.application.routes.draw do
  get 'user/recent_projects' => 'users#load_recent_projects'
end
