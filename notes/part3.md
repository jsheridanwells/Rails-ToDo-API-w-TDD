# Build a RESTful JSON API w/ Rails and RSpec PART THREE
From [this tutorial](https://scotch.io/tutorials/build-a-restful-json-api-with-rails-5-part-one).

__Part three will cover serialization, versioning, and pagination__

## Versioning

Organizing API into versions involves:
 * Adding a route constraint
 * Namespacing the controllers

1. Create a new class called ApiVersion that will check API version and route to appropriate controller module:
```
$ touch app/lib/api_version.rb
```

2. Implement API version:
```
# app/lib/api_version.rb
class ApiVersion
  attr_reader :version, :default

  def initialize(version, default = false)
    @version = version
    @default = default
  end

  # check whether version is specified or is default
  def matches?(request)
    check_headers(request.headers) || default
  end

  private

  def check_headers(headers)
    # check version from Accept headers; expect custom media type `todos`
    accept = headers[:accept]
    accept && accept.include?("application/vnd.todos.#{version}+json")
  end
end
```

## Content Negotiation

Content negotiation is the ability for a RESTful API to serve different representations of an API at the same URI.

1. Move todos and items resources into a V1 namespace in `routes.rb`:
```
# config/routes.rb
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # namespace the controllers without affecting the URI
  scope module: :v1, constraints: ApiVersion.new('v1', true) do
    resources :todos do
      resources :items
    end
  end

  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'
end

```

2. Move todos and items controllers to V1 namespace.  Set up v1 directory:
```
$ mkdir app/controllers/v1
```

3. Move todos and items controllers into v1:
```
$ mv app/controllers/{todos_controller.rb,items_controller.rb} app/controllers/v1
```

4. Wrap todos and items controllers in v1 namespace:
```
# app/controllers/v1/todos_controller.rb
module V1
  class TodosController < ApplicationController
  # [...]
  end
end
```
```
# app/controllers/v1/items_controller.rb
module V1
  class ItemsController < ApplicationController
  # [...]
  end
end
```

__Tests should pass and todos and items endpoints should respons when `Accept:'application/vnd.todos.v1+json'` is added to the request header.__

## Serializers

1. Add `active_model_serializers` to Gemfile:
```
# Gemfile
# [...]
  gem 'active_model_serializers', '~> 0.10.0'
# [...]
```

2. Bundle install

3. Generate a serializer: `$ rails g serializer todo`

4. Define the todo serializer:
```
# app/serializers/todo_serializer.rb
class TodoSerializer < ActiveModel::Serializer
  # attributes to be serialized  
  attributes :id, :title, :created_by, :created_at, :updated_at
  # model association
  has_many :items
end
```

__Tests should pass and GET /todos/:id should return array of related items__

## Pagination

1. Add the will_paginate gem:
```
# Gemfile
# [...]
  gem 'will_paginate', '~> 3.1.0'
# [...]
```

2. Bundle install

3. Modify todos#index to paginate responses:
```
# app/controllers/v1/todos_controller.rb
module V1
  class TodosController < ApplicationController
  # [...]
  # GET /todos
  def index
    # get paginated current user todos
    @todos = current_user.todos.paginate(page: params[:page], per_page: 20)
    json_response(@todos)
  end
  # [...]
end
```

4. Hitting GET /todos?page=1 should get first 20 results 

5. Optional: Create seed data to demo multiple result pages
a. Install Faker: `gem 'faker'` (or move out of :test group)
b. Create seed loop:
```
# db/seeds.rb
# seed 50 records
50.times do
  todo = Todo.create(title: Faker::Lorem.word, created_by: User.first.id)
  todo.items.create(name: Faker::Lorem.word, done: false)
end
```

