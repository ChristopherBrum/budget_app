# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'minitest/reporters'
Minitest::Reporters.use!
require 'simplecov'
SimpleCov.start

require_relative '../budget'