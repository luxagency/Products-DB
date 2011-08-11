class AddBrandFields < ActiveRecord::Migration
  def self.up
    add_column :products, :brand_name, :string
    add_column :products, :brand_url, :string
  end

  def self.down
    remove_column :products, :brand_url
    remove_column :products, :brand_name
  end
end