source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.0'

gem 'rails-i18n', '~> 5.1.3'

gem 'knock'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'active_model_serializers'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem 'bootsnap', '>= 1.1.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :test do
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails', '~> 3.8'
  gem 'rspec_junit_formatter'
  gem 'rubocop', require: false
end

group :development do
  gem 'annotate'
  gem 'bullet'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
