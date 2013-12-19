source 'http://rubygems.org'

gem 'rails', '~> 3.2.11'

gem 'simple_form'
gem 'htmlentities'
gem 'nokogiri'

# Web server
gem 'thin'

# Database
gem 'mongoid'
gem 'bson_ext'

# Background tasks
gem 'delayed_job_mongoid'
gem 'daemons'

# Deploy
gem 'capistrano'

# Authentication
gem 'devise', '~> 2.0.0'
gem 'cancan'

# Uploads
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'rmagick'
gem 'rubyzip'
gem 'ruby-netcdf'

# Test
group :development, :test do
  gem 'rspec-rails', '~> 2.12.0'
  gem 'spork', '0.9.2'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'mongoid-rspec'
  gem 'database_cleaner'
end

# Asset related
gem 'therubyracer'
gem 'jquery-rails'

group :assets do
  # JavaScript compressor
  gem 'uglifier'

  # Less rails
  gem 'less-rails-bootstrap'
end