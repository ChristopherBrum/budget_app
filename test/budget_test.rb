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
    assert_includes(last_response.body, "Add Funds")
    assert_includes(last_response.body, "Add Expense Category")
    assert_includes(last_response.body, "Add Transaction")
    assert_includes(last_response.body, "Delete Budget")
  end

  def test_add_funds_page
    get '/add_funds'
    assert_equal(200, last_response.status)
    assert_equal('text/html;charset=utf-8', last_response["Content-Type"])
    assert_includes(last_response.body, "Funds to be Added:")
    assert_includes(last_response.body, "Add Funds")
  end

  def test_add_funds
    post '/budget/create', budget_name: "House Budget"
    #### Create a seprate method for this? Setup??
    assert_equal(0, session[:budget].balance)

    post '/add_funds', deposit_amount: 1000
    assert_equal(302, last_response.status)
    assert_equal('text/html;charset=utf-8', last_response["Content-Type"])
    assert_equal(1000, session[:budget].balance)
  end
end