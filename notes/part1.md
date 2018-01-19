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

## Config

1. Add the following to `spec/rails_helper.rb`:
```
require 'database_cleaner'

# [...]
# configure shoulda matchers to use rspec as the test framework and full matcher libraries for rails
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# [...]
RSpec.configuration do |config|
  # [...]
  # add `FactoryGirl` methods
  config.include FactoryGirl::Syntax::Methods

  # start by truncating all the tables but then use the faster transaction strategy the rest of the time.
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  # start the transaction strategy as examples are run
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
  # [...]
end
```

## Generate Models

1. Create ToDo model: `$ rails g model Todo title created_by`

2. Create the Item model: `$ rails g model Item name done:boolean todo:references`

3. Run the migrations: `$ rails db:migrate`

## Model Specs

1. In todo_spec.rb:
```
require 'rails_helper'

# Test suite for the Todo model
RSpec.describe Todo, type: :model do
  # Association test
  # ensure Todo model has a 1:m relationship with the Item model
  it { should have_many(:items).dependent(:destroy) }
  # Validation tests
  # ensure columns title and created_by are present before saving
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:created_by) }
end
```

2. In item_spec.rb:
```
require 'rails_helper'

# Test suite for the Item model
RSpec.describe Item, type: :model do
  # Association test
  # ensure an item record belongs to a single todo record
  it { should belong_to(:todo) }
  # Validation test
  # ensure column name is present before saving
  it { should validate_presence_of(:name) }
end
```

3. Tests should fail.

4. Fix Todo model:
```
class Todo < ApplicationRecord
  # model association
  has_many :items, dependent: :destroy

  # validations
  validates_presence_of :title, :created_by
end
```

5. Fix Item model:
```
class Item < ApplicationRecord
  # model association
  belongs_to :todo

  # validation
  validates_presence_of :name
end
```

6. All tests should pass