require File.dirname(__FILE__) + "/spec_helper"

describe "App" do
  
  def app
    @app ||= Sinatra::Application
  end

  it "should increace clicks count for given product and redirect to product link" do
    site = Site.create(:name => "sample", :url => "http://style.com")
    product = Product.create(:title => "Hello", :link => "http://dummy.com", :image_url => "something")

    expect {
      get "/goto/#{product.id}/site_id/#{site.id}"
    }.to change{Site.find(site.id).clicks || 0}.by(1)

    last_response.status.should == 302
    last_response.headers["location"].should == "http://dummy.com"
  end
  
end