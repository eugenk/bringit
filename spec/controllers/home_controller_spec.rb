require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'new' without login" do
    it "returns http success" do
      get 'index'
      response.should_not be_success
    end
  end

  describe "GET 'new' after login" do
    before { login_user }
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end
end
