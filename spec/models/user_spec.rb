require 'spec_helper'

describe User do
  before do
    @user = User.new(email: "eugenk@tzi.de", 
                     password: "password", password_confirmation: "password")
  end
  
  subject { @user }
  
  [:email, :password, :password_confirmation, :remember_me].each do |field|
    it { should respond_to(field) }
  end
  
  it { should be_valid }
  
  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end
  
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end
  
  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end
  
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end
  
  describe "when password confirmation is nil" do
    before { @user.password_confirmation = "" }
    it { should_not be_valid }
  end
  
  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 7 }
    it { should be_invalid }
  end
  
  describe "with a password that's too long" do
    before { @user.password = @user.password_confirmation = "a" * 129 }
    it { should be_invalid }
  end
  
  describe "email address with mixed case" do
    let(:mixed_case_email) { "EUgenK@TZI.de" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end
end
