class Product < ActiveRecord::Base
  validates_presence_of :image_url, :title, :link
  validates_length_of :image_url, :title, :link, :minimum => 1, :allow_blank => false
  # validates_uniqueness_of :link
  belongs_to :category
  belongs_to :brand
  has_and_belongs_to_many :tags

  default_scope order('created_at DESC')

  def local_url(site_id)
    "/goto/#{id}/site_id/#{site_id}"
  end

  def tags_clicks_plus_one(site_id = 0)
    self.tags.each{|tag|
      Click.plus_one_for_tag(site_id, tag.id)
    }
  end

  def tag_id=(id)
    self.tag_ids = self.tag_ids << id.to_i unless id.to_i == 0
  end

  def link_with_referrals
    parsed_link = link
    Referral.all.each{|referral|
      if parsed_link.match referral.site
        join_symbol = parsed_link["?"] ? "&" : "?"
        parsed_link += join_symbol + referral.referral_string
        break
      end
    }
    parsed_link
  end
end