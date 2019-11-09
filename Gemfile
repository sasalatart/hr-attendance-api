source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.0'

gem 'rails-i18n', '~> 5.1.3'

gem 'jwt'
gem 'knock'
gem 'bcrypt', '~> 3.1.7'
gem 'cancancan'

gem 'kaminari'
gem 'api-pagination'
gem 'active_model_serializers'

gem 'validates_timeliness', '~> 5.0.0.alpha3'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem 'bootsnap', '>= 1.1.0', require: false

gem 'rack-cors'

gem 'faker'

group :test do
  gem 'factory_bot_rails'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 3.8'
  gem 'shoulda-matchers'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
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
