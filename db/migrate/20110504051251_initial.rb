class Initial < ActiveRecord::Migration
  def self.up
		create_table :products do |t|
      t.string :image_url
      t.string :link
      t.string :title
    end
    
    create_table :sites do |t|
      t.string :name
      t.string :url
      t.integer :clicks, :deault => 0
    end
  end

  def self.down
 		drop_table :products
    drop_table :sites
  end
end
