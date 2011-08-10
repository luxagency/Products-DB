RACK_ENV = "test"
require File.join(File.dirname(__FILE__), "..", "app.rb")

require "rubygems"
require 'bundler'
require "sinatra"
require "rack/test"
require "rspec"
# require 'spork'
require 'simplecov'

SimpleCov.start do 
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/db/'    
  add_filter '/views/'
end

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false


RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end