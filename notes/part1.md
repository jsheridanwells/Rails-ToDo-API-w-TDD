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

## Setup Controllers (and Request specs)

1. Create controllers:
```
$ rails g controller Todos
$ rails g controller Items
```

2. Since this is an API, we'll use REQUEST specs instead of CONTROLLER specs. Request specs hit endpoints like a client would while controller specs only test controller actions. Create requests directory and specs:
```
$ mkdir spec/requests/{todos_spec.rb,items_spec.rb}
```

3. Create factory files:
```
$ touch spec/factories/{todos.rb,items.rb}
```

4. Define the factories:
```
# spec/factories/todos.rb
FactoryGirl.define do
  factory :todo do
    title { Faker::Lorem.word }
    created_by { Faker::Number.number(10) }
  end
end

spec/factories/items.rb
FactoryGirl.define do
  factory :item do
    name { Faker::StarWars.character }
    done false
    todo_id nil
  end
end
```

## Set up API tests

1. `# spec/requests/todos_spec.rb`
```
require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  # initialize test data 
  let!(:todos) { create_list(:todo, 10) }
  let(:todo_id) { todos.first.id }

  # Test suite for GET /todos
  describe 'GET /todos' do
    # make HTTP get request before each example
    before { get '/todos' }

    it 'returns todos' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /todos/:id
  describe 'GET /todos/:id' do
    before { get "/todos/#{todo_id}" }

    context 'when the record exists' do
      it 'returns the todo' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(todo_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:todo_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end
  end

  # Test suite for POST /todos
  describe 'POST /todos' do
    # valid payload
    let(:valid_attributes) { { title: 'Learn Elm', created_by: '1' } }

    context 'when the request is valid' do
      before { post '/todos', params: valid_attributes }

      it 'creates a todo' do
        expect(json['title']).to eq('Learn Elm')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/todos', params: { title: 'Foobar' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Created by can't be blank/)
      end
    end
  end

  # Test suite for PUT /todos/:id
  describe 'PUT /todos/:id' do
    let(:valid_attributes) { { title: 'Shopping' } }

    context 'when the record exists' do
      before { put "/todos/#{todo_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # Test suite for DELETE /todos/:id
  describe 'DELETE /todos/:id' do
    before { delete "/todos/#{todo_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
```

2. Create `json` helper method:
```
$ mkdir spec/support && touch spec/support/request_spec_helper.rb
```

3. ...in the file:
```
module RequestSpecHelper
  # Parse JSON response to ruby hash
  def json
    JSON.parse(response.body)
  end
end
```

4. In `rails_helper.rb`, comment out support directory autoloading. Make sure the following lines are included:
```
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

config.include RequestSpecHelper
```
(See [this example for rails_helper.rb config](https://github.com/akabiru/todos-api/blob/master/spec/rails_helper.rb))

5. Tests should fail (routes are not yet defined).