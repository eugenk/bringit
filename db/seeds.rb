# Create Users
User.create!({ 
  email: 'user@example.com',
  password: "password",
  password_confirmation: "password"
})

10.times do |n|
  User.create!({ 
    email: Faker::Internet.email,
    password: "password#{n}",
    password_confirmation: "password#{n}"
  })
end

10.times do
  Repository.create!({
    title: Faker::Lorem.words(rand(2)+2, true).join(' '),
    description: Faker::Lorem.paragraph(rand(3)+1),
    owners: User.all[rand(3)..rand(3)+5],
  }).tap do |repo|
    5.times do
      repo.commit_file(repo.owners.first, Faker::Lorem.sentences(rand(7)+1).join('\n'), "#{Faker::Name.name}.txt", Faker::Lorem.sentences(rand(2)+1).join('\n'))
    end
  end
end
