class PostPicture < ActiveRecord::Base
  belongs_to :post, :polymorphic => true

  include Rails.application.routes.url_helpers

  mount_uploader :image, ImageUploader

  def to_jq_upload
  {
    "name" => read_attribute(image),
    "url" => image.url,
    "size" => image.size,
    "delete_url" => post_picture_path(:id => id),
    "delete_type" => "DELETE"
  }
  end
end
