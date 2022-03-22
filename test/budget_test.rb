# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'minitest/reporters'
Minitest::Reporters.use!
require 'simplecov'
SimpleCov.start

require_relative '../budget'

class TestBudget < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def create_budget
    post '/budget/create', budget_name: "Test Budget"
  end
    
  def session
    last_request.env["rack.session"]
  end

  def test_index_page
    get '/'
    assert_equal(200, last_response.status)
    assert_equal('text/html;charset=utf-8', last_response["Content-Type"])
    assert_includes(last_response.body, "Welcome to Budget App")
    assert_includes(last_response.body, "Create Budget")
  end

  def test_make_a_budget
    post '/budget/create'
    assert_equal(302, last_response.status)
    assert_equal('text/html;charset=utf-8', last_response["Content-Type"])

    get '/'
    assert_includes(last_response.body, "Add/Deduct Funds")
    assert_includes(last_response.body, "Add Expense Category")
    assert_includes(last_response.body, "Add Transaction")
    assert_includes(last_response.body, "Delete Budget")
  end

  def test_our_test_budget_object
    create_budget
    assert_equal(302, last_response.status)
    assert_equal(0, session[:budget].balance)
    assert_equal("Test Budget", session[:budget].name)
  end

  def test_add_funds_page
    create_budget

    get '/budget/add_funds', deposit_amount: "5000"
    assert_equal(200, last_response.status)
    assert_equal('text/html;charset=utf-8', last_response["Content-Type"])
    assert_includes(last_response.body, "Add or Deduct Funds:")
    assert_includes(last_response.body, "Amount to be added or deducted:")
    assert_includes(last_response.body, "Add/Deduct Funds")
    assert_includes(last_response.body, "Funds History:")
  end

  def test_deposit_funds
    create_budget

    post '/budget/add_funds', deposit_amount: 1000
    assert_equal(302, last_response.status)
    assert_equal('text/html;charset=utf-8', last_response["Content-Type"])
    assert_equal(1000, session[:budget].balance)
  end

  def test_deposit_funds_message
    create_budget
    post '/budget/add_funds', deposit_amount: 1000
    
    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "You've successfully added funds.")
    assert_includes(last_response.body, "Current Balance: <strong>$1000</strong>")
  end

  def test_withdraw_funds
    create_budget
    post '/budget/add_funds', deposit_amount: -500
    
    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_equal(-500, session[:budget].balance)
  end

  def test_withdraw_funds_message
    create_budget
    post '/budget/add_funds', deposit_amount: -500
    
    get last_response["Location"]
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "You've successfully deducted funds.")
    assert_includes(last_response.body, "Current Balance: $<strong>-500</strong>")
  end

  def test_funds_history
    
  end
end