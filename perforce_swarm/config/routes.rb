Rails.application.routes.draw do
  project_routes = [:configure_helix_mirroring,
                    :enable_helix_mirroring,
                    :disable_helix_mirroring]
  resources :namespaces, path: '/', constraints: { id: /[a-zA-Z.0-9_\-]+/ }, only: [] do
    resources(:projects, constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ }, only:
                           project_routes, path: '/') do
      member do
        get :configure_helix_mirroring
        post :enable_helix_mirroring
        post :disable_helix_mirroring
      end
    end
  end

  namespace :perforce_swarm, path: '/gitswarm' do
    resource :git_fusion, only: [], controller: :git_fusion do
      get :new_project
      get :existing_project
      post :reenable_helix_mirroring
      get :reenable_helix_mirroring_status
      get :reenable_helix_mirroring_redirect
    end

    resource :p4_tree, only: [:show], controller: :p4_tree
  end
end
