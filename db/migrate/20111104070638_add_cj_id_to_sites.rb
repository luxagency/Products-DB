class AddCjIdToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :cj_id, :string
  end

  def self.down
    remove_column :sites, :cj_id, :string
  end
end
