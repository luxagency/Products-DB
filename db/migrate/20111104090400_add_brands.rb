class AddBrands < ActiveRecord::Migration
  def self.up
    create_table :brands do |t|
      t.string :name
      t.string :url
    end

    add_column :products, :brand_id, :integer
  end

  def self.down
    remove_column :products, :brand_id
    drop_table :brands
  end
end

