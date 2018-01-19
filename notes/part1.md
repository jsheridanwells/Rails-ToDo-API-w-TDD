# Build a RESTful JSON API w/ Rails and RSpec
From [this tutorial](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-one).

## Dependency Setup

__Gemfile.rb:__
1. Rspec-rails to development and test groups
```
group :development, :test do
  gem 'rspec-rails', '~> 3.5'
end
```

2. Add FactoryGirl, Shoula, Faker, and DatabaseCleaner
```
group :test do
  gem 'factory_girl_rails', '~> 4.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'database_cleaner'
end
```

3. Install: `$ bundle install`

4. Initialize RSpec: `$ rails g rspec:install`

5. Create a /factories directory for FactoryGirl: `$ mkdir spec/factories`

