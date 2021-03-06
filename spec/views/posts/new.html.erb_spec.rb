require 'spec_helper'

describe "posts/new" do
  before(:each) do
    assign(:post, stub_model(Post,
      :title => "MyString",
      :description => "MyString",
      :content => "MyText",
      :address => "MyString",
      :latitude => 1.5,
      :longitude => 1.5,
      :user_id => 1
    ).as_new_record)
  end

  it "renders new post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", posts_path, "post" do
      assert_select "input#post_title[name=?]", "post[title]"
      assert_select "input#post_description[name=?]", "post[description]"
      assert_select "textarea#post_content[name=?]", "post[content]"
      assert_select "input#post_address[name=?]", "post[address]"
      assert_select "input#post_latitude[name=?]", "post[latitude]"
      assert_select "input#post_longitude[name=?]", "post[longitude]"
      assert_select "input#post_user_id[name=?]", "post[user_id]"
    end
  end
end
