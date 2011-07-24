require "sinatra"
require "sinatra/activerecord"
require "sinatra/base"
require "active_record"
require "uri"
require "haml"
require "./helpers.rb"

dbconfig = YAML.load(File.read("config/database.yml"))
RACK_ENV = "development"
SITE_ID = 1
PP = 6
ActiveRecord::Base.establish_connection dbconfig[RACK_ENV]


## models ##
class Product < ActiveRecord::Base
  validates_presence_of :image_url, :title, :link
  # validates_uniqueness_of :link
  
  def local_url(site_id)
    "/goto/#{id}/site_id/#{site_id}"
  end
end

class Site < ActiveRecord::Base
  validates_presence_of :name, :url
  validates_uniqueness_of :url
end


## actions ##

  get "/" do   
    protected!
    haml :index
  end

  ## products ##
  get "/products" do
    params[:site_id] ||= SITE_ID
    @products = Product.all(:limit => PP*3)
    haml :products_index
  end
  
  get '/products/next/:index' do
    @products = Product.all(:limit => PP, :offset => params[:index].to_i * PP)
    haml :products_next, :layout => false
  end

  get "/products/new" do
    protected!
    @product = Product.new
    haml :products_new
  end
  
  get "/products/admin" do
    protected!
    @products = Product.all
    haml :products_admin
  end
  
  get "/products/:id/edit" do
    protected!
    @product = Product.find(params[:id])
    
    haml :products_new
  end
  
  post "/products/:id" do
    protected!
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product])
    if @product.save
      redirect '/products'
    else
      @errors = true
      haml :products_new
    end
  end

  post "/products" do
    protected!
    @product = Product.create(params[:product]) 
    if @product.save
      redirect "/products"
    else
      @errors = true
      haml :products_new
    end
  end
  
  ## sites ##
  get "/sites" do
    protected!
    @sites = Site.all
    haml :sites_index
  end

  get "/sites/new" do
    protected!
    @site = Site.new
    haml :sites_new
  end

  post "/sites" do
    protected!
    @site = Site.new(params[:site]) 
    if @site.save
      redirect "/sites"
    else
      @errors = true
      haml :sites_new
    end
  end
  
  get "/sites/:id/edit" do
    protected!
    @product = Product.find(params[:id])
    
    haml :products_new
  end
  
  post "/sites/:id" do
    protected!
    @site = Site.find(params[:id])
    @site.update_attributes(params[:site])
    if @site.save
      redirect '/sites'
    else
      @errors = true
      haml :sites_new
    end
  end
  
  ## redirect ##
  get "/goto/:id/site_id/:site_id" do
    @site = Site.find(params[:site_id])
    @site.clicks = (@site.clicks || 0) + 1
    @site.save
    
    @product = Product.find(params[:id])
    redirect @product.link
  end