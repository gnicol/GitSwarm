Rails.application.routes.draw do
  devise_scope :user do
    get 'user/recent_projects' => 'application#load_user_projects'
  end

  resources :namespaces do
    resources :projects do
      member do
        get :configure_mirroring
        post :enable_mirroring
      end
    end
  end

  namespace :perforce_swarm,  path: '/gitswarm' do
    resource :git_fusion, only: [], controller: :git_fusion do
      get :new_project
      get :existing_project
    end
  end
end
