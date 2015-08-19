Rails.application.routes.draw do
  devise_scope :user do
    get 'user/recent_projects' => 'application#load_user_projects'
  end

  namespace :import do
    resource :git_fusion, only: [], controller: :git_fusion do
      get :configure
    end
  end
end
