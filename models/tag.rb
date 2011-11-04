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