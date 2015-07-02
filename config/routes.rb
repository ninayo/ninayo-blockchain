Rails.application.routes.draw do

  scope "(:locale)", locale: /en|sw/ do

    namespace "admin" do
      root :to => "analytics#index"
      resources :analytics
    end

    resources :ads do
      put :favorite
    end

    get 'ads/:id/preview' => 'ads#preview', as: :preview_ad
    get 'ads/:id/archive' => 'ads#archive', as: :archive_ad
    delete 'ads/:id/delete' => 'ads#delete', as: :delete_ad
    get 'ads/:id/rate_seller' => 'ads#rate_seller', as: :rate_seller
    get 'ads/:id/infopanel' => 'ads#infopanel', as: :infopanel
    patch 'ads/:id/save_buy_info' => 'ads#save_buy_info', as: :save_buy_info
    post 'ads/:id/contact-info' => 'ads#contact_info', as: :show_contact_info

    get 'map' => 'ads#map'

    get 'terms' => 'home#terms', as: :terms

    get 'mypage' => 'mypage#index', as: :mypage
    get 'mypage/current' => 'mypage#index', as: :mypage_current
    get 'mypage/favorites' => 'mypage#favorites', as: :mypage_favorites
    get 'mypage/archive' => 'mypage#archive', as: :mypage_archive

    devise_for :users
    # The priority is based upon order of creation: first created -> highest priority.
    # See how all your routes lay out with "rake routes".
  end

  get '/:locale' => 'ads#index'
  root 'ads#index'

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
