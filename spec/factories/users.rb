FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { "#{name}@example.com" }
    password '123456'
  end
end