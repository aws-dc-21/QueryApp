source 'https://rubygems.org'

gem 'rails', '4.0.1'
gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass', '~> 2.3.2.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 1.2'
gem 'simple_form'

group :doc do
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'rspec-rails'
end

group :development, :test do
  gem 'puma'
  gem 'quiet_assets'
  gem 'dotenv-rails'
  gem 'activerecord-jdbcsqlite3-adapter', :require => 'jdbc-sqlite3', :require => 'arjdbc'
end

group :production do
  gem 'activerecord-jdbcmysql-adapter', '1.3.0'
end
