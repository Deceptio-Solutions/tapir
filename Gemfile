source 'http://rubygems.org'

# Require recent Rails:
gem 'rails', '3.1.2'
# Use edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

# Console
gem 'pry'

# Rails / Database
gem 'sqlite3'
gem 'therubyracer'

# EAR Data manipulation
gem 'fastercsv'
gem 'librex'
gem 'nmap-parser'
gem 'json'

# Data Formats
gem 'exifr'

# Network Services:

gem 'dnsruby'
gem 'geoip'
gem 'whois'
gem 'packetfu'

# Web Services
gem 'linkedin'
gem 'flickr'

# Scraping
gem 'nokogiri'

# Heavy-duty javascript scraping
gem 'selenium-webdriver' # browser based scraping with capybara
gem 'capybara'

group :pain do

  # Postgres database
  # apt-get install libpq-dev
  gem 'pg'

  # Requires QTwebkit
  # https://github.com/thoughtbot/capybara-webkit#readme
  # apt-get install libqt4-dev
  gem 'capybara-webkit'

  # Requires Libpcap-dev
  # apt-get install libpcap-dev
  gem 'pcaprub'
  
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5.rc.2'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
end
