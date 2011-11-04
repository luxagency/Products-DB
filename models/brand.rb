class Brand < ActiveRecord::Base

  has_many :products

  def self.to_options
    all.collect{|cat| [cat.name, cat.id]}
  end

end