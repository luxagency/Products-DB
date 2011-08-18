require File.dirname(__FILE__) + "/spec_helper"

describe Tag do
  it "should validates_presence_of :name" do
    s = Tag.new
    s.should_not be_valid
    v = Tag.new(:name => '2')
    v.should be_valid
  end
end

describe "Tag Actions" do
  def app
    @app ||= Sinatra::Application
  end

  context "acceptance" do
    before(:each) do
      authorize "admin", "rob"
    end

    it "should have form fields for each attribute" do
      get '/tags/new'
      Tag.new.attributes.keys.each{|attr, _|
        last_response.body.should =~ /tag\[#{attr}\]/m
      }
    end
  end

  context "get" do
    before(:all) do
      Tag.delete_all
      Tag.create(:name => "google")
    end

    before(:each) do
      authorize "admin", "rob"
    end

    ["/tags", "/tags/new"].each do |url|
      it "should render page #{url}" do
        authorize "admin", "rob"
        get url
        last_response.should be_ok
      end
    end

    it "should render page /tags/1/edit" do
      Tag.delete_all
      t = Tag.create(:name => "something")
      get "/tags/#{t.id}/edit"
      last_response.should be_ok
    end
  end

  context "post" do
    before(:each) do
      authorize "admin", "rob"
      Tag.delete_all
    end

    context "invalid" do
      it "should return errors when new tag is invalid" do
        expect {
          post "/tags", :tag => {}
        }.to_not change{Tag.count}
      end

      it "should return errors while trying to edit unknown tag" do
        expect {
          post "/tags/999", :tag => {:name => "lala"}
        }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "valid" do
      it "should create valid tag" do
        expect {
          post "/tags", :tag => {:name => "lala"}
        }.to change{Tag.count}

        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/tags"
      end

      it "should update valid tag" do
        tag = Tag.create(:name => "something")
        post "/tags/#{tag.id}", :tag => {:name => 'something new'}
        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/tags"

        t2 = Tag.find(tag.id)
        t2.name.should == 'something new'
      end
    end

  end
end