source 'https://rubygems.org'
gemspec

group :development do
  # for gems that are nice in development
  # but don't break the build when missing
  # Example: deubgger
  gem 'debugger'

  gem "guard", "~> 1.6.2"
  gem "guard-rspec", "~> 2.5.0"

  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
end

group :test do
  gem 'rake'
  gem 'rspec'
end
