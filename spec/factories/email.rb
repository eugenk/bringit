FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com" 
  end
end