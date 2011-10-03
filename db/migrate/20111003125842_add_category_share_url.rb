class AddCategoryShareUrl < ActiveRecord::Migration
  def self.up
    add_column :categories, :share_url, :string
    add_column :categories, :twitter, :string
  end

  def self.down                       
    remove_column :categories, :share_url
    remove_column :categories, :twitter
  end
end
