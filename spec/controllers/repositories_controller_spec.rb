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
  
  describe "POST not 'create'" do
    it "returns no http success" do
      post 'create'
      response.should_not be_success
    end
  end
    
  describe "GET 'new'" do
    before { login_user }
    
    it "returns http success" do
      get 'new'
      response.should be_success
    end
    
    it "assign repository as @repository" do
      get 'new'
      assigns(:repository).should be_a_new(Repository)
    end
  end
  
  describe "POST create" do
    before { login_user }
    
    it "returns http success" do
      post 'create'
      response.should be_success
    end
    
    describe "with valid params" do
      it "creates a new repository" do
        expect {
          post :create, {repository: FactoryGirl.attributes_for(:repository)}
        }.to change(Repository, :count).by(1)
      end

      it "assigns a newly created repository as @repository" do
        post :create, {repository: FactoryGirl.attributes_for(:repository)}
        assigns(:repository).should be_a(Repository)
        assigns(:repository).should be_persisted
      end

      it "redirects to the created repository" do
        post :create, {repository: FactoryGirl.attributes_for(:repository)}
        response.should redirect_to(Repository.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved repository as @repository" do
        # Trigger the behavior that occurs when invalid params are submitted
        FactoryGirl.build_stubbed(:repository).stub(:save).and_return(false)
        post :create, {repository: {}}
        assigns(:repository).should be_a_new(Repository)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        FactoryGirl.build_stubbed(:repository).stub(:save).and_return(false)
        post :create, {repository: {}}
        response.should render_template("_new")
      end
    end
  end
end