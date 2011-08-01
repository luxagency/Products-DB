class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
    end
    
    add_column :products, :category_id, :integer
  end

  def self.down
    remove_column :products, :category_id
    drop_table :categories
  end
end
