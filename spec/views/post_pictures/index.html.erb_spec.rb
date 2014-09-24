require 'spec_helper'

describe "post_pictures/index" do
  before(:each) do
    assign(:post_pictures, [
      stub_model(PostPicture,
        :post_id => 1,
        :image => "Image"
      ),
      stub_model(PostPicture,
        :post_id => 1,
        :image => "Image"
      )
    ])
  end

  it "renders a list of post_pictures" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Image".to_s, :count => 2
  end
end
