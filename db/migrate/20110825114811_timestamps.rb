class Timestamps < ActiveRecord::Migration
  def self.up
    [:products, :sites, :categories, :tags, :referrals].each do |s|
      change_table s do |t|
        t.timestamps
      end
    end
  end

  def self.down
  end
end
