require 'spec_helper'

describe "posts/show" do
  before(:each) do
    @post = assign(:post, stub_model(Post,
      :title => "Title",
      :description => "Description",
      :content => "MyText",
      :address => "Address",
      :latitude => 1.5,
      :longitude => 1.5,
      :user_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/Description/)
    rendered.should match(/MyText/)
    rendered.should match(/Address/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/1/)
  end
end
