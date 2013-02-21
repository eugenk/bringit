# Create Users
10.times do |n|
  User.create!({ 
    email: Faker::Internet.email,
    password: "password#{n}",
    password_confirmation: "password#{n}"
  })
end



def create_commit(push, parents = [])
  push.git_commits.create!({
    commit_hash: SecureRandom.hex(20),
    committer_name: Faker::Name.name,
    committer_email: Faker::Internet.email,
    committer_time: Time.now - rand(28*3600*24),
    message: Faker::Lorem.sentences(rand(2)+1), #TODO: long commit messages
    git_push: push,
    parents: parents
  })
end

5.times do
  GitRepository.create!({
    title: Faker::Lorem.words(rand(2)+1),
    description: Faker::Lorem.paragraph(rand(3)+1),
    owners: [User.first],
    path: Faker::Lorem.words(rand(4)+1).split(' ').join('/')
  }).tap do |repo|
    5.times do
      repo.git_pushes.create!({
        author: repo.owners.first,
        push_type: 'web',
        git_repository: repo
      }).tap do |push|
        3.times do
          create_commit(push, [create_commit(push), create_commit(push)])
        end
      end
    end
  end
end

