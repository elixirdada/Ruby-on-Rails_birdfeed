Rails.application.routes.draw do
  mount Shrine.presign_endpoint(:store) => "/presign"
  mount LetterOpenerWeb::Engine, at: "/letter_opener"

  devise_for :users, path: 'usr', controllers: {
        registrations: 'users/registrations',
        sessions: 'users/sessions',
        omniauth_callbacks: 'users/omniauth_callbacks',
        passwords: 'users/passwords'
      }

  devise_scope :user do
    get 'usr/edit_profile', :to => 'users/registrations#edit_profile'
    put 'usr/update_profile', :to => 'users/registrations#update_profile'
    get 'usr/edit_account', :to => 'users/registrations#edit_account'
    put 'usr/update_account', :to => 'users/registrations#update_account'
    get 'usr/link_sent', :to => 'users/passwords#link_sent'
  end

  resources :users, only: [:show, :index, :update] do
    collection do
      post "change_avatar"
    end
  end
  get 'load_more_leaders', to: 'users#load_more'
  get 'load_more_artists', to: 'users#load_more_artists'

  post '/rate' => 'rater#create', :as => 'rate'
  get "leaderboard", to: "users#leaderboard"
  get "choose_profile", to: "users#choose_profile"
  get "get_more_credits", to: "users#get_more_credits"
  get "success_signup", to: "users#success_signup"
  get "terms_and_conduct", to: "users#terms_and_conduct"
  delete "cancel_subscription", to: "users#cancel_subscription"
  post "apply_promocode", to: "users#apply_promocode"
  get "home", to: "users#home"
  get "final_cancellation", to: "home#final_cancellation"

  post "report", to: "home#report"

  # user profile settings urls
  get "usr/rewards", to: 'user_profile_settings#rewards'
  get "usr/egg_credits", to: 'user_profile_settings#egg_credits'
  get "usr/headers", to: 'user_profile_settings#headers'
  get "usr/skins", to: 'user_profile_settings#skins'
  get "usr/downloads", to: 'user_profile_settings#downloads'
  get "usr/billing_order_history", to: 'user_profile_settings#billing_order_history'
  get "usr/friends", to: 'user_profile_settings#friends'
  get "usr/artists", to: 'user_profile_settings#artists'
  get "usr/releases", to: 'user_profile_settings#releases'
  get "usr/chirp_feeds", to: 'user_profile_settings#chirp_feeds'
  get "usr/notifications", to: 'user_profile_settings#notifications'
  get "usr/integrations", to: 'user_profile_settings#integrations'
  get "usr/cancel_account", to: 'user_profile_settings#cancel_account'
  put "usr/update_notification_settings", to: 'user_profile_settings#update_notification_settings', :as => 'update_notification_settings'
  put "usr/update_user_header", to: 'user_profile_settings#update_user_header', :as => 'update_user_header'
  delete "usr/cancel_account", to: 'user_profile_settings#cancel_account_perform'

  get "get_feed_token", to: "feeds#get_feed_token"
  get "add_feed_item", to: "feeds#add_feed_item"
  get "add_notify_item", to: "feeds#add_notify_item"
  get "load_more_feed", to: "feeds#load_more"
  get "is_seen", to: "feeds#is_seen"
  get "is_read", to: "feeds#is_read"

  get "chirp_feed", to: "users#chirp_feed"
  get "release_feed", to: "users#release_feed"
  get "artists_feed", to: "users#artists_feed"
  get "friends_feed", to: "users#friends_feed"
  get "announcement_feed", to: "users#announcement_feed"
  get "interviews_feed/:id", to: "users#interviews_feed", as: "interviews_feed"
  get "videos_feed/:id", to: "users#videos_feed", as: "videos_feed"
  get "others_feed/:id", to: "users#others_feed", as: "others_feed"
  get "friends/:id", to: "users#friends", as: "friends"
  get "idols/:id", to: "users#idols", as: "idols"

  ActiveAdmin.routes(self)

  devise_scope :user do
    authenticated do
      root 'users#home', as: :authenticated_root
    end
  end

  get 'admins/:id', to: 'users#admin', as: 'admin'
  get 'artists/:id', to: 'users#artist', as: 'artist'
  get 'artist_releases/:id', to: 'users#artist_releases', as: 'artist_releases'
  get 'artist_tracks/:id', to: 'users#artist_tracks', as: 'artist_tracks'
  get 'artists', to: 'users#artists'
  get 'badges/:id', to: 'users#badges', as: 'badges'

  get 'what-is-birdfeed', to: 'home#about'
  get 'support', to: 'home#support'
  get 'support_message', to: 'home#support_message'
  post 'create_support', to: 'home#create_support'
  get 'listen', to: 'home#listen'
  get 'connect', to: 'home#connect'
  get 'play', to: 'home#play'
  get 'birdfeed', to: 'home#birdfeed'
  post 'share', to: 'home#share'
  get 'badge-notify', to: 'home#badge_notify'
  get 'pricing', to: 'home#pricing'
  get 'information', to: 'home#information'
  get 'privacy', to: 'home#information'
  get 'terms', to: 'home#information'
  get 'how_eggs_work', to: 'home#how_eggs_work'

  resources :contacts, only: [:index, :create]
  resources :slider_images

  resources :announcements, only: [:show]
  resources :releases, only: [:show, :index]
  get '/releases/:id/download', to: 'releases#download', as: :release_download
  get '/tracks/:id/download', to: 'tracks#download', as: :track_download
  get "search_releases", to: "releases#search"
  get "fill_track_title", to: "tracks#fill_track_title"
  get 'load_more_releases', to: 'releases#load_more'

  resources :tracks
  get 'track_listened', to: 'tracks#track_listened'
  get 'track_listened_for_review', to: 'tracks#track_listened_for_review'
  get 'tracks_play', to: 'tracks#play'
  get 'tracks_list', to: 'tracks#list'
  get 'track_clicked', to: 'tracks#track_clicked'

  resources :onboarding do
    get 'onboarding_complete'
    get 'step_2'
    get 'step_3'
    get 'step_4'
  end

  resources :player do
    get 'liked_playlists'
    get 'liked_tracks'
    get 'recently_tracks'
    get 'downloaded_tracks'
    get 'favorites'
    get 'connect'
    get 'listen'
    get 'artists'
    get 'fans'
    get 'playlists'
    get 'badges'
    get 'play'
    get 'friends'
    get 'all_badges'
    get 'my_badges'
    get 'headers_and_skins'
    get 'gaming_points'
  end
  get 'player_load_more_leaders', to: 'player#load_more_fans'
  get 'player_load_more_artists', to: 'player#load_more_artists'

  resources :playlists, except: [:new]
  get 'playlist_load', to: "playlists#load"
  post "sync_playlist", to: "playlists#sync_playlist"
  get 'new_playlist_view', to: "playlists#new_playlist_view", as: "new_playlist"
  get 'add_to_playlist_view', to: "playlists#add_to_playlist_view", as: "add_to_playlist"
  get 'change_playlist_view', to: "playlists#change_playlist_view", as: "change_playlist"

  namespace :callbacks do
    post 'transloadit', to: 'transloadit#create'
    post 'braintree/nonce', to: 'braintree#nonce'
    post 'braintree/update_cc', to: 'braintree#update_cc'
    # post 'braintree/analytics_notify', to: 'braintree#analytics_notify'
  end


  resources :topics
  resources :posts

  resources :follows
  get '/accept_request/:user_id/', to: 'follows#accept_request', as: :accept_request
  get '/reject_request/:user_id/', to: 'follows#reject_request', as: :reject_request
  get 'is_seen_requests', to: 'follows#is_seen_requests'


  resources :comments
  get 'comment_reply_form', to: 'comments#reply_form'
  get 'post_create_form', to: 'posts#new_form'

  resources :likes

  resources :chirp, controller: 'topic_categories', only: [:show, :index] do
    # get 'category/:id', to: "topics#category"
    resources :topics
    # get 'pin'
    # get 'unpin'
    # get 'lock'
    # get 'unlock'
  end

  resources :notifications

  root "home#index"

  mount Shrine.presign_endpoint(:store) => "/presign"
end
