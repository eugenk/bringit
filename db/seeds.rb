# Create Users
User.create!({ 
  email: 'user@example.com',
  password: "password",
  password_confirmation: "password"
})

20.times do |n|
  User.create!({ 
    email: Faker::Internet.email,
    password: "password#{n}",
    password_confirmation: "password#{n}"
  })
end


def create_commit(push, parents = [])
  push.commits.create!({
    commit_hash: SecureRandom.hex(20),
    committer_name: Faker::Name.name,
    committer_email: Faker::Internet.email,
    committer_time: Time.now - rand(28*3600*24),
    message: Faker::Lorem.sentences(rand(2)+1).join('\n'),
    push: push,
    parents: parents
  })
end

30.times do
  Repository.create!({
    title: Faker::Lorem.words(rand(2)+2, true).join(' '),
    description: Faker::Lorem.paragraph(rand(3)+1),
    owners: User.all[rand(10)..rand(10)+7],
  }).tap do |repo|
    5.times do
      repo.pushes.create!({
        author: repo.owners.first,
        push_type: 'web',
        repository: repo
      }).tap do |push|
        3.times do
          create_commit(push, [create_commit(push), create_commit(push)])
        end
      end
    end
  end
end

