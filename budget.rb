require 'yaml'
require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

configure do
  enable :sessions
  # BCryptd from "secret"
  set :session_secret, "$2a$12$pDQdMRa2yNfWPOqDtU.7vuqDkdhQ8M94pV/b6TRa0pfHyv8KOnXc6"
end

########## Classes ##########

class Budget
  def initialize
  end
end

class Category
  def initialize
  end
end

class Transaction
  def initialize
  end
end

before do
  @session = session
end

########## Methods ##########

def logged_in?
  !session[:user].nil?
end

########## Routes ##########

get '/' do
  unless logged_in?
    redirect '/login'
  end

  erb :index
end

# Display login form
get '/login' do
  
  
  erb :login
end

# Display form to add funds
get '/add_funds' do

  erb :add_funds
end

# add funds to current balance
post '/add_funds' do

  redirect '/'
end
