json.array!(@post_pictures) do |post_picture|
  json.extract! post_picture, :post_id, :image
  json.url post_picture_url(post_picture, format: :json)
end