require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "sinatra/base"
require "active_record"
require "uri"
require "haml"
require "bundler/setup"


# App
require "./helpers.rb"
require "./models.rb"

dbconfig = YAML.load(File.read("config/database.yml"))
RACK_ENV ||= ENV["RACK_ENV"] || "development"
SITE_ID = 1
PER_PAGE = 6 # per page
ActiveRecord::Base.establish_connection dbconfig[RACK_ENV]


## actions ##
  get "/" do
    protected!
    haml :index
  end

  ## products ##
  get "/products" do
    params[:site_id] ||= SITE_ID
    category = params[:category_id] ? {:category_id => params[:category_id]} : {}
    @products = Product.all(:limit => PER_PAGE*3, :conditions => category)
    haml :products_index
  end

  get '/products/next/:index' do
    category = params[:category_id] ? {:category_id => params[:category_id]} : {}
    @products = Product.all(:limit => PER_PAGE, :offset => params[:index].to_i * PER_PAGE, :conditions => category)
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
      redirect '/products/admin'
    else
      @errors = true
      haml :products_new
    end
  end

  post "/products" do
    protected!
    @product = Product.new(params[:product])
    @product.tag_id = params[:product][:tag_id]
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
    @site = Site.find(params[:id])

    haml :sites_new
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

  ## categories ##

  get "/categories" do
    protected!
    @categories = Category.all
    haml :categories_index
  end

  get "/categories/new" do
    protected!
    @category = Category.new
    haml :categories_new
  end

  post "/categories" do
    protected!
    @category = Category.new(params[:category])
    if @category.save
      redirect "/categories"
    else
      @errors = true
      haml :categories_new
    end
  end

  get "/categories/:id/edit" do
    protected!
    @category = Category.find(params[:id])

    haml :categories_new
  end

  post "/categories/:id" do
    protected!
    @category = Category.find(params[:id])
    @category.name = params[:category][:name]
    if @category.save
      redirect '/categories'
    else
      @errors = true
      haml :categories_new
    end
  end
  
  ## tags ##

  get "/tags" do
    protected!
    @tags = Tag.all
    haml :tags_index
  end

  get "/tags/new" do
    protected!
    @tag = Tag.new
    haml :tags_new
  end

  post "/tags" do
    protected!
    @tag = Tag.new(params[:tag])
    if @tag.save
      redirect "/tags"
    else
      @errors = true
      haml :tags_new
    end
  end

  get "/tags/:id/edit" do
    protected!
    @tag = Tag.find(params[:id])

    haml :tags_new
  end

  post "/tags/:id" do
    protected!
    @tag = Tag.find(params[:id])
    @tag.name = params[:tag][:name]
    if @tag.save
      redirect '/tags'
    else
      @errors = true
      haml :tags_new
    end
  end

  ## redirect ##
  get "/goto/:id/site_id/:site_id" do
    @product = Product.find(params[:id])

    # Update site clicks
    Site.clicks_plus_one(params[:site_id])

    # Update per category clicks
    Click.plus_one_for_category(params[:site_id], @product.category_id)
    # Update per tags clicks
    @product.tags_clicks_plus_one(params[:site_id])

    redirect @product.link
  end