require 'yaml'
require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

require 'pry'

configure do
  enable :sessions
  set :session_secret, 'session_secret_for_budget_app'
  disable :protection
end

########## Classes ##########

class Budget
  attr_reader :name
  attr_accessor :balance, :categories, :funds_log

  def initialize(name)
    @balance = 0
    @name = name
    @categories = []
    @funds_log = []
  end

  def add_funds(amount)
    self.balance = balance + amount.to_i
    add_funds_to_log(amount)
  end

  def new_category(title, allotted_amt)
    id = new_category_id
    @categories << Category.new(title, allotted_amt, id)
  end

  def find_category(id)
    @categories.select do |category|
      category if category.id == id
    end
  end

  def find_category_by_title(given_title)
    @categories.select { |category| category.title == given_title }.first
  end

  def calc_expenses
    total = 0
    @categories.each { |category| total += category.amount }
    total
  end

  def delete_category(id)
    index = nil

    @categories.each_with_index do |category, idx|
      if category.id == id
        index = idx
      end
    end

    @categories.delete_at(index)
  end

  private

  def add_funds_to_log(amount)
    if amount > 0
      @funds_log << { amount: amount, type: "deposit", date: DateTime.now }
    elsif amount < 0
      @funds_log << { amount: amount, type: "withdraw", date: DateTime.now }
    end
  end

  def new_category_id
    return 1 if @categories.empty?

    max = @categories.max_by { |category| category.id }
    max.id + 1
  end
end

class Category
  attr_accessor :title, :amount, :id, :transactions

  def initialize(title, amount, id)
    @title = title
    @amount = amount
    @id = id
    @transactions = []
  end

  def new_transaction(title, description, amount)
    id = new_transaction_id
    @transactions << Transaction.new(title, description, amount, id)
  end

  def find_transaction(id)

  end

  private

  def new_transaction_id
    return 1 if @transactions.empty?

    max = @transactions.max_by { |category| category.id }
    max.id + 1
  end
end

class Transaction
  attr_reader :category, :description, :amount, :id

  def initialize(category, description, amount, id)
    @category = category
    @description = description
    @amount = amount
    @id = id
  end
end

########## Methods ##########

def select_category(id)
  @budget.categories.select { |category| category.id == id }.first
end

def all_transactions
  @budget.categories.each_with_object([]) do |category, array|
    category.transactions.each { |transaction| array << transaction }
  end
end

def transactions_total
  all_transactions.map do |transaction|
    transaction.amount.to_i
  end.sum
end

def current_balance
  @budget.balance - transactions_total
end

########## Routes ##########

before do
  @budget = session[:budget]
  @session = session.inspect
end

get '/' do
  erb :index
end

########## CATEGORY ##########

# display new category form
get '/category/new' do
  erb :add_category
end

# Create new category
post '/category/create' do
  title = params[:cat_title]
  allotted_funds = params[:cat_allotted_funds].to_i

  @budget.new_category(title, allotted_funds)
  session[:message] = "The category #{title} has been created."
  redirect '/'
end

# Display form to edit category
get '/category/:category_id' do
  @id = params[:category_id].to_i
  @category = select_category(@id)

  erb :category
end

post '/category/:category_id/edit' do
  id = params[:category_id].to_i
  category = select_category(id)

  category.title = params[:cat_title]
  category.amount = params[:cat_allotted_funds].to_i
  session[:message] = "#{category.title} has been updated."
  redirect '/'
end

# Delete category
post '/category/:category_id/delete' do
  id  = params[:category_id]
  delete_category(@budget.categories)
end

########## TRANSACTIONS ##########

get '/transaction/add' do
  erb :add_transaction
end

post '/transaction/create' do
  category = params[:category]
  description = params[:description]
  amount = params[:transaction_amt].to_i
  category = @budget.find_category_by_title(category)

  category.new_transaction(category, description, amount)
  session[:message] = "A new transaction has been entered."

  puts params ## not needed
  
  redirect '/'
end

########## BUDGET ##########

# Display form to add funds
get '/budget/add_funds' do
  erb :add_funds
end

# add funds to current balance
post '/budget/add_funds' do
  deposit_amount = params[:deposit_amount].to_i

  if deposit_amount > 0
    @budget.add_funds(deposit_amount)
    session[:message] = "You've successfully added funds."
    redirect '/'
  elsif deposit_amount < 0
    @budget.add_funds(deposit_amount)
    session[:message] = "You've successfully deducted funds."
    redirect '/'
  else
    session[:message] = "You must enter a positive or negative number. "
    erb :add_funds
  end
end

# Create a new budget
post '/budget/create' do
  session[:budget] = Budget.new(params[:budget_name])
  redirect '/'
end

# Delete the budget
post "/budget/delete" do
  session.delete(:budget)
  redirect '/'
end