require File.dirname(__FILE__) + "/spec_helper"

describe Category do
  it "should validates_presence_of :name" do
    s = Category.new
    s.should_not be_valid
    v = Category.new(:name => '2')
    v.should be_valid
  end
end

describe "Category Actions" do 
  def app
    @app ||= Sinatra::Application
  end
  
  context "get" do
    before(:all) do
      Category.delete_all
      Category.create(:name => "google")
    end
    
    before(:each) do
      authorize "admin", "rob"
    end
    
    ["/categories", "/categories/new"].each do |url|
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
      Category.delete_all
    end
    
    context "invalid" do
      it "should return errors when new category is invalid" do
        expect {
          post "/categories", :category => {}
        }.to_not change{Category.count}
      end
    end
    
    context "valid" do
      it "should create valid category" do
        expect {
          post "/categories", :category => {:name => "lala"}
        }.to change{Category.count}

        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/categories"
      end
    end
    
  end
end