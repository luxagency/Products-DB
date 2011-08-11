require File.dirname(__FILE__) + "/spec_helper"

describe Referral do
  it "should validates_presence_of :site, :referral_string" do
    s = Referral.new
    s.should_not be_valid
    v = Referral.new(:site => 'amazon', :referral_string => 'hello=world')
    v.should be_valid
  end
end

describe "Referral Actions" do
  def app
    @app ||= Sinatra::Application
  end

  context "acceptance" do
    before(:each) do
      authorize "admin", "rob"
    end

    it "should have form fields for each attribute" do
      get '/referrals/new'
      Referral.new.attributes.keys.each{|attr, _|
        last_response.body.should =~ /referral\[#{attr}\]/m
      }
    end
  end

  context "get" do
    before(:all) do
      Referral.delete_all
      Referral.create(:site => 'amazon', :referral_string => 'hello=world')
    end

    before(:each) do
      authorize "admin", "rob"
    end

    ["/referrals", "/referrals/new"].each do |url|
      it "should render page #{url}" do
        authorize "admin", "rob"
        get url
        last_response.should be_ok
      end
    end

    it "should render page /referrals/1/edit" do
      Referral.delete_all
      t = Referral.create(:site => 'amazon', :referral_string => 'hello=world')
      get "/referrals/#{t.id}/edit"
      last_response.should be_ok
    end
  end

  context "post" do
    before(:each) do
      authorize "admin", "rob"
      Referral.delete_all
    end

    context "invalid" do
      it "should return errors when new referral is invalid" do
        expect {
          post "/referrals", :referral => {}
        }.to_not change{Referral.count}
      end

      it "should return errors while trying to edit unknown referral" do
        expect {
          post "/categories/999", :referral => {:site => "lala"}
        }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "valid" do
      it "should create valid referral" do
        expect {
          post "/referrals", :referral => {:site => 'amazon', :referral_string => 'hello=world'}
        }.to change{Referral.count}

        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/referrals"
      end

      it "should update valid referral" do
        referral = Referral.create(:site => 'amazon', :referral_string => 'hello=world')
        post "/referrals/#{referral.id}", :referral => {:site => 'something new'}
        last_response.status.should == 302
        last_response.headers["location"].should == "http://example.org/referrals"

        t2 = Referral.find(referral.id)
        t2.site.should == 'something new'
      end
    end

  end
end