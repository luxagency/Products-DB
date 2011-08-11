class AddBrancreateReferals < ActiveRecord::Migration
  def self.up
    create_table :referrals do |t|
      t.string :site
      t.string :referral_string
    end
  end

  def self.down
    drop_table :referrals
  end
end
