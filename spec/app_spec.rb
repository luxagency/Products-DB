require File.dirname(__FILE__) + '/spec_helper'

describe "App" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  context "basic http" do
    ["/", "/products/new", "/sites", "/sites/new"].each do |url|
      it "should require http_authentication #{url}" do
        get url
        last_response.status.should == 401
      end

      it "should not render with bad credentials #{url}" do
        authorize 'bad', 'boy'
        get url
        last_response.status.should == 401
      end

      it "should render well with good creds #{url}" do
        authorize 'admin', 'rob'
        get url
        last_response.should be_ok
      end
    end

    it "should respond to /products and not require http_authentication" do
      get '/products'
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

  context "posts" do

    before(:each) do
      authorize 'admin', 'rob'
      Product.delete_all
      Site.delete_all
    end

    context "invalid" do
      it "should return errors when new product is invalid" do
        expect {
          post "/products", :product => {:title => 'lala'}
        }.to_not change{Product.count}
      end

      it "should return errors when new site is invalid" do
        expect {
          post "/sites", :site => {:name => 'lala'}
        }.to_not change{Site.count}
      end
    end
    context "valid" do
      it "should create valid product" do
        expect {
          post "/products", :product => {:title => 'lala', :link => "http://link.com", :image_url => 'http://something.jpg'}
        }.to change{Product.count}

        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/products"
      end

      it "should create valid site" do
        expect {
          post "/sites", :site => {:name => 'lala', :url => "http://link.com"}
        }.to change{Site.count}

        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/sites"
      end
    end

    it "should increace clicks count for given product and redirect to product link" do
      site = Site.create(:name => 'sample', :url => "http://style.com")
      product = Product.create(:title => 'Hello', :link => 'http://dummy.com', :image_url => 'something')

      expect {
        get "/goto/#{product.id}/site_id/#{site.id}"
      }.to change{Site.find(site.id).clicks || 0}.by(1)

      last_response.status.should == 302
      last_response.headers["location"].should == "http://dummy.com"
    end
  end
end