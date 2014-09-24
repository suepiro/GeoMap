require 'spec_helper'

describe "post_pictures/show" do
  before(:each) do
    @post_picture = assign(:post_picture, stub_model(PostPicture,
      :post_id => 1,
      :image => "Image"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Image/)
  end
end
