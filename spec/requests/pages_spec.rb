require 'spec_helper'

describe "Pages" do
  subject { page }
  
  shared_examples_for "all pages" do
    it { should have_selector('h1',    text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end
  
  describe "Home" do
    before { visit root_path }
    
    let(:heading)    { 'Home' }
    let(:page_title) { '' }
    
    it_should_behave_like 'all pages'
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "Sign up"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "Sign in"
    page.should have_selector 'title', text: full_title('Sign in')
  end
  # for later use
  #it "should have the right links on the layout" do
  #  visit root_path
  #  click_link "Repositories"
  #  page.should have_selector 'title', text: full_title('Repositories')
  #end
end
