50.times do 
  todo = Todo.create(title: Faker::Lorem.word, created_by: User.first.id)
  10.times do
    todo.items.create(name: Faker::Lorem.word, done: false)
  end
end