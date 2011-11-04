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