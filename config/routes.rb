# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'user_token' => 'user_token#create'
  get '/users/me' => 'users#me'
  post '/attendances/check-ins' => 'attendances#check_in'
  put '/attendances/check-outs' => 'attendances#check_out'

  resources :organizations do
    resources :users, only: %i[index create update destroy], shallow: true
  end
end
