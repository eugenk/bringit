# Create Users
10.times do |n|
  User.create!({ 
    email: Faker::Internet.email,
    password: "password#{n}",
    password_confirmation: "password#{n}"
  })
end


5.times do
  repo = GitRepository.create({
    title: Faker::Lorem.words(rand(2)+1),
    description: Faker::Lorem.paragraph(rand(3)+1),
    owners: [User.first(offset: rand(User.count))],
    path: Faker::Lorem.words(rand(4)+1).split(' ').join('/')
  })
  
  
  5.times do
    push = GitPush.create({
      author: repo.owners.first,
      push_type: 'web',
      git_repository: repo
    })
    
    3.times do
      create_commit([create_commit, create_commit])
    end
  end
end


def create_commit(parents = [])
  GitCommit.create({
    commit_hash: Faker::Base.regexify(/^[a-f0-9]{40}$/),
    committer_name: Faker::Name.name,
    committer_email: Faker::Internet.email,
    committer_time: Time.at(rand_in_range(28.days.ago, Time.now)),
    message: Faker::Lorem.sentences(rand(2)+1), #TODO: long commit messages
    git_push: push,
    parents: parents
  })
end
