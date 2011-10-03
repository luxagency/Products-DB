require File.dirname(__FILE__) + "/spec_helper"

describe Product do
  it "should validates_presence_of :image_url, :title, :link " do
    p = Product.new
    p.should_not be_valid
    v = Product.new(:image_url => '2', :title => '2', :link => '2')
    v.should be_valid
  end

  it 'should have fields' do
    p = Product.new
    [:title, :link, :image_url, :brand_name, :brand_url].each do |field|
      p.respond_to?(field).should be_true
    end
  end
end

describe "Product Actions" do
  def app
    @app ||= Sinatra::Application
  end

  let(:form_attributes) {
    Product.new.attributes.keys - ['created_at', 'updated_at']
  }

  context "acceptance" do
    before(:each) do
      authorize "admin", "rob"
    end

    it "should have form fields for each attribute" do
      get '/products/new'
      form_attributes.each{|attr, _|
        last_response.body.should =~ /product\[#{attr}\]/m
      }
    end
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

    it "should render page /products/1/edit" do
      p = Product.create(:image_url => 'http://google.com/google.png', :title => "something", :link => 'link')
      get "/products/#{p.id}/edit"
      last_response.should be_ok
    end

    it "/products/next/2 should return offsetted collection" do
      Product.delete_all
      10.times {|i|
        Product.create(:image_url => 'http://google.com/google.png', :title => "p#{i}", :link => "link#{i}")
      }
      get "products/next/1"
      last_response.should be_ok
      last_response.body.should =~ /p6/m
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

      it "should return errors while trying to edit unknown product" do
        expect {
          post "/products/999", :product => {:title => "lala"}
        }.should raise_error(ActiveRecord::RecordNotFound)
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

      it "should update valid product" do
        p = Product.create(:image_url => 'http://google.com/google.png', :title => "something", :link => 'link')
        post "/products/#{p.id}", :product => {:title => 'something new'}
        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/products/admin"

        p2 = Product.find(p.id)
        p2.title.should == 'something new'
      end
    end

  end
end