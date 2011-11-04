class RemoveBrandTextFields < ActiveRecord::Migration
  def self.up
    remove_column :products, :brand_url
    remove_column :products, :brand_name
  end

  def self.down
    add_column :products, :brand_name, :string
    add_column :products, :brand_url, :string
  end
end
