require 'spec_helper'

describe "posts/index" do
  before(:each) do
    assign(:posts, [
      stub_model(Post,
        :title => "Title",
        :description => "Description",
        :content => "MyText",
        :address => "Address",
        :latitude => 1.5,
        :longitude => 1.5,
        :user_id => 1
      ),
      stub_model(Post,
        :title => "Title",
        :description => "Description",
        :content => "MyText",
        :address => "Address",
        :latitude => 1.5,
        :longitude => 1.5,
        :user_id => 1
      )
    ])
  end

  it "renders a list of posts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
