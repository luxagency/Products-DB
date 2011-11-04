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