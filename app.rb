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
  belongs_to :category
  has_and_belongs_to_many :tags

  def local_url(site_id)
    "/goto/#{id}/site_id/#{site_id}"
  end

  def tags_clicks_plus_one(site_id = 0)
    self.tags.each{|tag|
      Click.clicks_plus_one_for_tag(site_id, tag.id)
    }
  end

  def tag_id=(id)
    self.tag_ids = self.tag_ids << id.to_i unless id.to_i == 0
  end
end

class Click < ActiveRecord::Base
  belongs_to :site
  belongs_to :category

  def clicks_plus_one_for_category(site_id, category_id)
    clicks = Click.find_or_initialize_by_site_id_and_category_id(site_id, category_id)
    clicks.update_attribute(:clicks, (clicks.clicks || 0) + 1)
  end

  def clicks_plus_one_for_tag(site_id, tag_id)
    clicks = Click.find_or_initialize_by_site_id_and_tag_id(site_id, tag_id)
    clicks.update_attribute(:clicks, (clicks.clicks || 0) + 1)
  end
end


class Site < ActiveRecord::Base
  validates_presence_of :name, :url
  validates_uniqueness_of :url

  def clicks_per_category
    Click.all(:conditions => {:site_id => self.id}).collect{|c|
      "#{c.category}: #{c.clicks}"
    }.join("<br />")
  end

  def self.clicks_plus_one(site_id)
    site = Site.find()
    site.clicks = (@site.clicks || 0) + 1
    site.save
  end
end

class Category < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s
    name
  end

  def self.to_options
    all.collect{|cat| [cat.name, cat.id]}
  end

end

class Tag < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :products

  def to_s
    name
  end

  def self.to_options
    all.collect{|tag| [tag.name, tag.id]}
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
    category = params[:category_id] ? {:category_id => params[:category_id]} : {}
    @products = Product.all(:limit => PP*3, :conditions => category)
    haml :products_index
  end

  get '/products/next/:index' do
    category = params[:category_id] ? {:category_id => params[:category_id]} : {}
    @products = Product.all(:limit => PP, :offset => params[:index].to_i * PP, :conditions => category)
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