require File.dirname(__FILE__) + '/spec_helper'

describe "App" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end

  it "should respond to /products" do
    get '/products'
    last_response.should be_ok
  end

  it "should respond to /products/new" do
    get '/products/new'
    last_response.should be_ok
  end

  it "should respond to /sites" do
    get '/sites'
    last_response.should be_ok
  end
  
  it "should respond to /sites/new" do
    get '/sites/new'
    last_response.should be_ok
  end
  
  it "should return the correct content-type when viewing root" do
    get '/'
    last_response.headers["Content-Type"].should == "text/html;charset=utf-8"
  end
  
  it "should return 404 when page cannot be found" do
    get '/404'
    last_response.status.should == 404
  end
  
end