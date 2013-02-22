FactoryGirl.define do
  factory :user, aliases: [:author, :owner] do
    email 
    password "password"
    password_confirmation "password"
  end
end