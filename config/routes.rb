Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, only: :omniauth_callbacks, controllers: { omniauth_callbacks: 'omniauth_callbacks' }

  mount Split::Dashboard, at: 'split'

  get "/metabase" => redirect("https://ninayometabase.herokuapp.com"), :as => :metabase
  get "/wp-login.php" => redirect("http://goatse.ru")

  scope "(:locale)", locale: /en|sw/ do

    namespace :api, defaults: {format: :json} do
      post 'ads' => 'ussd#post_ad'
      get 'ads' => 'ussd#get_ads_for_user'
      get 'archive/:id' => 'ussd#archive_ad'
      get 'units' => 'ussd#get_units'
      get 'crops' => 'ussd#get_crop_types'
      get 'regions' => 'ussd#get_regions'
    end

    namespace :bot, defaults: {format: :json} do
      get 'postad' => 'bot#post_ad'
      get 'linkuser' => 'bot#link_facebook'
      get 'fb_auth' => 'bot#auth_link'
    end

    # old deprecated routes for the former admin panel
    # namespace "admin" do
    #   root :to => "analytics#index"
    #   get 'analytics/index' => 'analytics#index', as: :analytics
    #   get 'analytics/ads-per-day' => 'analytics#ads_per_day', as: :ads_per_day
    #   get 'analytics/logins-per-day' => 'analytics#logins_per_day', as: :logins_per_day
    #   get 'analytics/users' => 'analytics#users', as: :analytics_users
    #   get 'analytics/all_ads' => 'analytics#all_ads', as: :analytics_all_ads
    # end

    resources :ads do
      put :favorite
      resources :comments
    end

    resources :comments do
      resources :comments
    end

    resources :conversations, only: [:index, :show, :destroy] do
      member do
        post :reply
      end
    end

    resources :post_imports

    resources :messages, only: [:new, :create]

    resources :invites, only: [:index, :create]

    resources :help_requests, only: [:new, :create, :index]
    get 'help_requests/close_help_request/:id' => 'help_requests#close_help_request', as: :close_ticket
    get 'help_requests/closed' => 'help_requests#closed_index', as: :closed_request_index

    #get 'admin_announce' => 'messages#message_all'

    get 'ads/:id/preview' => 'ads#preview', as: :preview_ad
    get 'ads/:id/archive' => 'ads#archive', as: :archive_ad
    delete 'ads/:id/delete' => 'ads#delete', as: :delete_ad
    get 'ads/:id/rate_seller' => 'ads#rate_seller', as: :rate_seller
    get 'ads/:id/infopanel' => 'ads#infopanel', as: :infopanel
    patch 'ads/:id/save_buy_info' => 'ads#save_buy_info', as: :save_buy_info
    post 'ads/:id/contact-info' => 'ads#contact_info', as: :show_contact_info
    get 'ads/:id/spam' => 'ads#mark_as_spam', as: :spam_ad

    get 'ads/:id/call' => 'ads#call_contact', as: :call_contact
    get 'ads/:id/text' => 'ads#text_contact', as: :text_contact
    get 'ads/:id/whatsapp' => 'ads#whatsapp_contact', as: :whatsapp_contact

    get 'map' => 'ads#map'

    get 'terms' => 'home#terms', as: :terms

    get 'mypage' => 'mypage#index', as: :mypage
    get 'mypage/current' => 'mypage#current', as: :mypage_current
    get 'mypage/favorites' => 'mypage#favorites', as: :mypage_favorites
    get 'mypage/archive' => 'mypage#archive', as: :mypage_archive

    get 'splash/instructions' => 'splash#instructions', as: :splash_instructions
    get 'splash/get_started' => 'splash#get_started', as: :get_started
    get 'splash/team' => 'splash#team', as: :team
    get 'splash/congrats' => 'splash#congrats', as: :congrats

    get 'sponsors' => 'sponsor#show', as: :sponsors

    #get 'prices' => 'prices#dar', as: :prices
    #get 'prices/new' => 'prices#new', as: :new_price
    #post 'prices' => 'prices#create', as: :create_price
    #get 'prices/dar' => 'prices#dar', as: :dar_price
    #get 'prices/mbeya' => 'prices#mbeya', as: :mbeya_price
    #get 'prices/iringa' => 'prices#iringa', as: :iringa_price
    #get 'prices/dar_new' => 'prices#new_dar_price', as: :new_dar_price
    #get 'prices/iringa_new' => 'prices#new_iringa_price', as: :new_iringa_price
    #get 'prices/mbeya_new' => 'prices#new_mbeya_price', as: :new_mbeya_price

    #devise_for :users, :controllers => { :sessions => "track_sessions" }
    # The priority is based upon order of creation: first created -> highest priority.
    # See how all your routes lay out with "rake routes".

    devise_for :users, skip: :omniauth_callbacks, controllers: { registrations: 'users/registrations', sessions: 'track_sessions' }

  end

  post 'envayaportal', to: 'text_messages#envaya_endpoint'

  post 'text', to: 'text_messages#create'

  patch 'sms_reset/:phone_number' => 'text_messages#find_for_sms_reset', as: :sms_reset

  get 'harvest_reminder' => 'text_messages#harvest_reminder', as: :harvest_reminder
  get 'seller_followup' => 'text_messages#weekly_sms_prices', as: :seller_followup 
  get 'bart_ad' => 'text_messages#mtenda_reminder', as: :bart_ad

  get '/.well-known/acme-challenge/ZfWSZ-8jDoGc8OenfP8JC79QPITHFU6BH9YPvVabGd8' => 'splash#letsencrypt_verify'

  get '/:locale' => 'splash#index'
  root 'splash#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
