source 'http://rubygems.org'

gem 'rake'
gem 'sinatra'
gem 'haml'
gem 'activerecord', "<= 2.3.11"
gem 'i18n'
gem 'sqlite3-ruby'
gem 'sinatra-activerecord'
gem "sinatra-reloader"

group :production do
  gem 'activerecord', "<= 2.3.11"
end

group :development, :test do
  gem "simplecov", ">=0.4.2"
  gem 'ruby-debug19'
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-core'
  gem 'autotest'
  gem 'autotest-growl'
end