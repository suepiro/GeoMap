require 'spec_helper'

describe "post_pictures/edit" do
  before(:each) do
    @post_picture = assign(:post_picture, stub_model(PostPicture,
      :post_id => 1,
      :image => "MyString"
    ))
  end

  it "renders the edit post_picture form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", post_picture_path(@post_picture), "post" do
      assert_select "input#post_picture_post_id[name=?]", "post_picture[post_id]"
      assert_select "input#post_picture_image[name=?]", "post_picture[image]"
    end
  end
end
