class CreateClicks < ActiveRecord::Migration
  def self.up
    create_table :clicks do |t|
      t.integer :site_id
      t.integer :category_id
      t.integer :clicks
    end
  end

  def self.down
    drop_table :clicks
  end
end
