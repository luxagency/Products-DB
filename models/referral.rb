class Referral < ActiveRecord::Base
  validates_presence_of :site, :referral_string

  def to_s
    site
  end

end