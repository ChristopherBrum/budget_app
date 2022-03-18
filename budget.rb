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
  attr_reader :balance, :name

  def initialize(name)
    @balance = 0
    @name = name
    @categories = []
  end
end

class Category
  def initialize(title, amount)
    @title = title
    @amount = amount
  end
end

class Transaction
  def initialize
  end
end

########## Methods ##########

def determine_balance
  session[:balance]== 0 ? NO_BALANCE : session[:balance]
end 

def add_funds(amount)
  if session[:budget].balance 
    session[:balance] += amount.to_i
  else
    session[:balance] = amount.to_i 
  end
end

########## Routes ##########

before do
  @budget = session[:budget]
  @balance = determine_balance
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

# Create a new budget
post '/budget/create' do
  session[:budget] = Budget.new(params[:budget_name])
  redirect '/'
end