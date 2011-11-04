require './app'
require 'sinatra/activerecord/rake'

desc "Dummy data"
task :seed do
  ["Sassy Bella", "College Fashion", "Style Clicker", "The Coveted", "Eco Chick" ].each do |name|
    Site.create(:name => name, :url => "http://#{name.downcase.gsub(' ','-')}.com")
  end

  5.times do |i|
    ["Reef - Reef Mood Bandeau Bra", "Rip Curl - Aloha Bandeau", "Tibi Solid American Bottom with Ring", "Juicy Couture Lacy Layers Ruffle", "Volcom - Smock Puppet One Piece", "Volcom - Stark Mark Solid Basic Halter Top", "Volcom - Pin Em Down Full Bottom"].each do |name|
      Product.create(:title => name, :link => "http://style.com/#{name.downcase.gsub(' ','-')}", :image_url => 'http://resources.shopstyle.com/sim/f0/ae/f0ae4f0b9c631fa5e18db0ec75ccbe8c_medium/aiko-bloomingdales-black-dresses-long-sleeve-jacquard-dress.jpg')
    end
  end

  ["Swim", "Dresses", "New Arrivals", "On Sale", "Bags", "Jewelry"].each{|cat|
    Category.create(:name => cat)
  }

  cat_ids = Category.all.collect(&:id)
  Product.all.each{|p|
    p.update_attribute(:category_id, cat_ids[rand(6)+1])
  }

end

task :reset do
  `touch db/development.db`
  `rake db:migrate`
  `rake seed`
end

