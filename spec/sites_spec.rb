require File.dirname(__FILE__) + "/spec_helper"

describe Site do
  it "should validates_presence_of :name, :url " do
    s = Site.new
    s.should_not be_valid
    v = Site.new(:name => '2', :url => '2')
    v.should be_valid
  end
end

describe "Site Actions" do 
  def app
    @app ||= Sinatra::Application
  end
  
  context "get" do
    before(:all) do
      Site.delete_all
      Site.create(:url => 'http://google.com/google.png', :name => "google")
    end
    
    before(:each) do
      authorize "admin", "rob"
    end
    
    ["/sites", "/sites/new"].each do |url|
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
      Site.delete_all
    end
    
    context "invalid" do
      it "should return errors when new site is invalid" do
        expect {
          post "/sites", :site => {:name => "lala"}
        }.to_not change{Site.count}
      end
    end
    
    context "valid" do
      it "should create valid site" do
        expect {
          post "/sites", :site => {:name => "lala", :url => "http://link.com"}
        }.to change{Site.count}

        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/sites"
      end
    end
    
  end
end