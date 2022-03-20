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

########## Classes ##########

class Budget
  attr_reader :name
  attr_accessor :balance, :categories

  def initialize(name)
    @balance = 0
    @name = name
    @categories = []
    @transactions = []
  end

  def new_category(title, allotted_amt)
    id = new_category_id
    @categories << Category.new(title, allotted_amt, id)
  end

  def category_title(id)
    @categories.each do |category|
      return category.title if category.id == id
    end
    "A category"
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

  def new_category_id
    return 1 if @categories.empty?

    max = @categories.max_by { |category| category.id }
    max.id + 1
  end
end

class Category
  attr_accessor :title, :amount, :id

  def initialize(title, amount, id)
    @title = title
    @amount = amount
    @id = id
  end
end

class Transaction
  def initialize
  end
end

########## Methods ##########

def add_funds(amount)
  @budget.balance = @budget.balance + amount.to_i
end

def select_category(id)
  @budget.categories.select { |category| category.id == id }.first
end
########## Routes ##########

before do
  @budget = session[:budget]
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
  deposit_amount = params[:deposit_amount].to_i

  if deposit_amount > 0
    add_funds(deposit_amount)
    session[:message] = "You've successfully added funds."
    redirect '/'
  elsif deposit_amount < 0
    add_funds(deposit_amount)
    session[:message] = "You've successfully deducted funds."
    redirect '/'
  else
    session[:message] = "You must enter a positive or negative number. "
    erb :add_funds
  end
end

# display new category form
get '/category/add' do
  erb :add_category
end

# Create new category
post '/category/add' do
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

# Delete a category
def delete_category(id)
  id = params[:category_id].to_i
  title = @budget.category_title(id)
  
  @budget.delete_category(id)
  session[:message] = "#{title} has been deleted."
  redirect '/'
end

# Delete category
post '/category/:category_id/delete' do
  id  = params[:category_id]
  delete_category(@budget.categories)
end

# Create a new budget
post '/budget/create' do
  session[:budget] = Budget.new(params[:budget_name])
  redirect '/'
end

# Delete the budget
post "/budget/delete" do

end