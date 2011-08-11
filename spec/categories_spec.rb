require File.dirname(__FILE__) + "/spec_helper"

describe Category do
  it "should validates_presence_of :name" do
    s = Category.new
    s.should_not be_valid
    v = Category.new(:name => '2')
    v.should be_valid
  end

  it 'should have fields' do
    p = Category.new
    [:name].each do |field|
      p.respond_to?(field).should be_true
    end
  end

end

describe "Category Actions" do
  def app
    @app ||= Sinatra::Application
  end

  context "acceptance" do
    before(:each) do
      authorize "admin", "rob"
    end

    it "should have form fields for each attribute" do
      get '/categories/new'
      Category.new.attributes.keys.each{|attr, _|
        last_response.body.should =~ /category\[#{attr}\]/m
      }
    end
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

    it "should render page /categories/1/edit" do
      Category.delete_all
      s = Category.create(:name => "something")
      get "/categories/#{s.id}/edit"
      last_response.should be_ok
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

      it "should return errors while trying to edit unknown category" do
        expect {
          post "/categories/999", :category => {:name => "lala"}
        }.should raise_error(ActiveRecord::RecordNotFound)
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

      it "should update valid category" do
        c = Category.create(:name => "something")
        post "/categories/#{c.id}", :category => {:name => 'something new'}
        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/categories"

        c2 = Category.find(c.id)
        c2.name.should == 'something new'
      end
    end

  end
end