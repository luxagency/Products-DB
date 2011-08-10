require File.dirname(__FILE__) + "/spec_helper"

describe Product do
  it "should validates_presence_of :image_url, :title, :link " do
    p = Product.new
    p.should_not be_valid
    v = Product.new(:image_url => '2', :title => '2', :link => '2')
    v.should be_valid
  end
end

describe "Product Actions" do 
  def app
    @app ||= Sinatra::Application
  end
  
  context "get" do
    before(:all) do
      Product.delete_all
      Product.create(:image_url => 'http://google.com/google.png', :title => "google", :link => 'link')
    end
    
    before(:each) do
      authorize "admin", "rob"
    end
    
    ["/products", "/products/next/:index", "/products/new", "/products/admin"].each do |url|
      it "should render page #{url}" do
        authorize "admin", "rob"
        get url
        last_response.should be_ok
      end
    end
  end
  
  context "post" do 
    before(:each) do
      authorize "admin", "rob"
      Product.delete_all
    end
    
    context "invalid" do
      it "should return errors when new product is invalid" do
        expect {
          post "/products", :product => {:title => "lala"}
        }.to_not change{Product.count}
      end
    end
    
    context "valid" do
      it "should create valid product" do
        expect {
          post "/products", :product => {:title => "lala", :link => "http://link.com", :image_url => "http://something.jpg"}
        }.to change{Product.count}

        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/products"
      end
    end
    
  end
end