Rails.application.routes.draw do
  resources :schedules, only: [:index]
  
  resources :invoices do
    member do
      get 'download', to: 'invoices#download', as: :download, defaults: { format: 'pdf' }
      get 'download_estimate', to: 'invoices#download_estimate', as: :download_estimate, defaults: { format: 'pdf' }
      get 'download_receipt', to: 'invoices#download_receipt', as: :download_receipt, defaults: { format: 'pdf' }
    end
  end
  
  resources :applications do
    collection do
      post :import
    end
    member do
      delete 'documents/:attachment_id', to: 'applications#purge_document', as: :purge_document
      patch 'documents/:attachment_id/info', to: 'applications#update_document_info', as: :update_document_info
    end
  end

  resources :customers do
    collection do
      post :import
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # データ分析ページ
  get 'analysis', to: 'dashboard#analysis', as: :analysis

  # Defines the root path route ("/")
  root "dashboard#index"
end
