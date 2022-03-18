require 'yaml'
require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'


configure do
  enable :sessions
  set :session_secret, 'session_secret_for_budget_app'
  disable :protection
end

########## Constants ##########

NO_BALANCE = "No money!"

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

########## Methods ##########

def determine_balance
  session[:balance].nil? ? NO_BALANCE : session[:balance]
end 

def add_funds(amount)
  if session[:balance].class == Integer
    session[:balance] += amount.to_i
  else
    session[:balance] = amount.to_i 
  end
end

########## Routes ##########

before do
  @balance = determine_balance
  session[:working] = true
  @session = session.inspect
end

get '/' do
  erb :index
end

# Display form to add funds
get '/add_funds' do
  erb :add_funds
end

# add funds to current balance
post '/add_funds' do
  add_funds(params[:deposit_amount])
  

  redirect '/'
end

