require 'spec_helper'

describe RepositoriesController do

  #before { login_user }

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
    
    it "assigns all repositories as @repositories" do
      repository = FactoryGirl.create(:repository)
      get :index, {}
      assigns(:repositories).should eq([repository])
    end
  end
  
  describe "GET 'search'" do
    it "returns http success" do
      get 'search'
      response.should be_success
    end
    
    it "assigns all repositories as @repositories" do
      repository = FactoryGirl.create(:repository)
      repository.title = 'repository'
      repository.save
      get :index, {term: 'repository'}
      assigns(:repositories).should eq([repository])
    end
  end
  
  
  describe "GET 'show'" do
    it "returns http success" do
      repository = FactoryGirl.create(:repository)
      get 'show', {id: 1}
      response.should be_success
    end
    
    it "assign repository as @repository" do
      repository = FactoryGirl.create(:repository)
      get 'show', {id: 1}
      assigns(:repository).should eq(repository)
    end
  end
    
  describe "GET not 'new'" do
    it "returns no http success" do
      get 'new'
      response.should_not be_success
    end
  end
    
  describe "GET 'new'" do
    before { login_user }
    
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end
  
end
