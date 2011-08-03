class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name
    end
    
    create_table :products_tags, :id => false do |t|
      t.integer :product_id
      t.integer :tag_id
    end
    
    add_column :clicks, :tag_id, :integer
  end

  def self.down
    remove_column :clicks, :tag_id
    drop_table :products_tags
    drop_table :tags
  end
end
