# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repository do
    sequence(:title) { |n| "Bringit #{n} " }
    description "bringit\nThe simple web-interface for git"
    before(:create) do |repository|
      repository_owner = FactoryGirl.create(:repository_owner, repository: repository)
      repository.repository_owners << FactoryGirl.create(:repository_owner, repository: repository)
      repository.owners << repository_owner.owner
    end
  end
end
