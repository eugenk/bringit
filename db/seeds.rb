# Create Users
10.times do |n|
  User.create!({ 
    email: Faker::Internet.email,
    password: "password#{n}",
    password_confirmation: "password#{n}"
  })
end