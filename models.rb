class Product < ActiveRecord::Base
  validates_presence_of :image_url, :title, :link
  validates_length_of :image_url, :title, :link, :minimum => 1, :allow_blank => false
  # validates_uniqueness_of :link
  belongs_to :category
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

class Click < ActiveRecord::Base
  belongs_to :site
  belongs_to :category
  belongs_to :tag

  def self.plus_one_for_category(site_id, category_id)
    clicks = Click.find_or_initialize_by_site_id_and_category_id(site_id, category_id)
    clicks.update_attribute(:clicks, (clicks.clicks || 0) + 1)
  end

  def self.plus_one_for_tag(site_id, tag_id)
    clicks = Click.find_or_initialize_by_site_id_and_tag_id(site_id, tag_id)
    clicks.update_attribute(:clicks, (clicks.clicks || 0) + 1)
  end
end


class Site < ActiveRecord::Base
  validates_presence_of :name, :url
  validates_uniqueness_of :url

  def clicks_per_category
    Click.all(:conditions => ['site_id = ? AND category_id IS NOT NULL', self.id]).collect{|c|
      "#{c.category}: #{c.clicks}"
    }.join("<br />")
  end

  def clicks_per_tag
    Click.all(:conditions => ['site_id = ? AND tag_id IS NOT NULL', self.id]).collect{|c|
      "#{c.tag}: #{c.clicks}"
    }.join("<br />")
  end

  def self.clicks_plus_one(site_id)
    site = Site.find(site_id)
    site.clicks = (site.clicks || 0) + 1
    site.save
  end
end

class Category < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s
    name
  end

  def self.to_options
    all.collect{|cat| [cat.name, cat.id]}
  end

end

class Tag < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :products

  def to_s
    name
  end

  def self.to_options
    all.collect{|tag| [tag.name, tag.id]}
  end

end

class Referral < ActiveRecord::Base
  validates_presence_of :site, :referral_string

  def to_s
    site
  end

end
