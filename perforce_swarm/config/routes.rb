Rails.application.routes.draw do
  namespace :import do
    resource :git_fusion, only: [:create, :new], controller: :git_fusion do
      get :status
      get :callback
      get :jobs
    end
  end
end
