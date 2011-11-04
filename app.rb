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

Dir.entries('/home/anton/!rb.projects/products-db/source/models/').each do |model|
  require './models/'+model if model != '.' && model != '..'
end

dbconfig = YAML.load(File.read("config/database.yml"))
RACK_ENV = ENV["RACK_ENV"] || "development"
SITE_ID = 1
ActiveRecord::Base.establish_connection dbconfig[RACK_ENV]
ActiveRecord::Base.logger = Logger.new(File.open("log/#{RACK_ENV}.log", "a"))

before do
  @per_page =
    case params[:width].to_s
      when '1'
        5
      when '2'
        4
      when '3'
        3
      else 6
    end
end


## actions ##
  get "/" do
    protected!
    haml :index
  end

  ## products ##
  get "/products" do
    params[:site_id] ||= SITE_ID
    @category = Category.find(params[:category_id]) if params[:category_id]

    @products = Product.all( :conditions => (params[:category_id] ? {:category_id => params[:category_id]} : {}) )

    @site = Site.find(params[:site_id])

    haml :"products/index"
  end

  get '/products/next/:index' do
    category = params[:category_id] ? {:category_id => params[:category_id]} : {}
    @products = Product.all(:limit => @per_page, :offset => params[:index].to_i * @per_page, :conditions => category)
    haml :"products/next", :layout => false
  end

  get "/products/new" do
    protected!
    @product = Product.new
    haml :"products/new"
  end

  get "/products/admin" do
    protected!
    @products = Product.all
    haml :"products/admin"
  end

  get "/products/:id/edit" do
    protected!
    @product = Product.find(params[:id])

    haml :"products/new"
  end

  post "/products/:id" do
    protected!
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product])
    if @product.save
      redirect '/products/admin'
    else
      @errors = true
      haml :"products/new"
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
      haml :"products/new"
    end
  end

  ## sites ##
  get "/sites" do
    protected!
    @sites = Site.all
    haml :"sites/index"
  end

  get "/sites/new" do
    protected!
    @site = Site.new
    haml :"sites/new"
  end

  post "/sites" do
    protected!
    @site = Site.new(params[:site])
    if @site.save
      redirect "/sites"
    else
      @errors = true
      haml :"sites/new"
    end
  end

  get "/sites/:id/edit" do
    protected!
    @site = Site.find(params[:id])

    haml :"sites/new"
  end

  post "/sites/:id" do
    protected!
    @site = Site.find(params[:id])
    @site.update_attributes(params[:site])
    if @site.save
      redirect '/sites'
    else
      @errors = true
      haml :"sites/new"
    end
  end

  ## categories ##

  get "/categories" do
    protected!
    @categories = Category.all
    haml :"categories/index"
  end

  get "/categories/new" do
    protected!
    @category = Category.new
    haml :"categories/new"
  end

  post "/categories" do
    protected!
    @category = Category.new(params[:category])
    if @category.save
      redirect "/categories"
    else
      @errors = true
      haml :"categories/new"
    end
  end

  get "/categories/:id/edit" do
    protected!
    @category = Category.find(params[:id])

    haml :"categories/new"
  end

  post "/categories/:id" do
    protected!
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      redirect '/categories'
    else
      @errors = true
      haml :"categories/new"
    end
  end
  
  ## tags ##

  get "/tags" do
    protected!
    @tags = Tag.all
    haml :"tags/index"
  end

  get "/tags/new" do
    protected!
    @tag = Tag.new
    haml :"tags/new"
  end

  post "/tags" do
    protected!
    @tag = Tag.new(params[:tag])
    if @tag.save
      redirect "/tags"
    else
      @errors = true
      haml :"tags/new"
    end
  end

  get "/tags/:id/edit" do
    protected!
    @tag = Tag.find(params[:id])

    haml :"tags/new"
  end

  post "/tags/:id" do
    protected!
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      redirect '/tags'
    else
      @errors = true
      haml :"tags/new"
    end
  end


  ## referrals ##

  get "/referrals" do
    protected!
    @referrals = Referral.all
    haml :"referrals/index"
  end

  get "/referrals/new" do
    protected!
    @referral = Referral.new
    haml :"referrals/new"
  end

  post "/referrals" do
    protected!
    @referral = Referral.new(params[:referral])
    if @referral.save
      redirect "/referrals"
    else
      @errors = true
      haml :"referrals/new"
    end
  end

  get "/referrals/:id/edit" do
    protected!
    @referral = Referral.find(params[:id])

    haml :"referrals/new"
  end

  post "/referrals/:id" do
    protected!
    @referral = Referral.find(params[:id])
    if @referral.update_attributes(params[:referral])
      redirect '/referrals'
    else
      @errors = true
      haml :"referrals/new"
    end
  end


## brands
get "/brands" do
  protected!
  @brands = Brand.all
  haml :"brands/index"
end

get "/brands/new" do
  protected!
  @brand = Brand.new
  haml :"brands/new"
end

post "/brands" do
  protected!
  @brand = Brand.new(params[:brand])
  if @brand.save
    redirect "/brands"
  else
    @errors = true
    haml :"brands/new"
  end
end

get "/brands/:id/edit" do
  protected!
  @brand = Brand.find(params[:id])

  haml :"brands/new"
end

post "/brands/:id" do
  protected!
  @brand = Brand.find(params[:id])
  if @brand.update_attributes(params[:brand])
    redirect '/brands'
  else
    @errors = true
    haml :"brands/new"
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

    redirect @product.link_with_referrals
  end