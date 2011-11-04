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