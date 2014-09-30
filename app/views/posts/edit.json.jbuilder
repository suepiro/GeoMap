json.array!(@posts) do |post|
  json.extract! post, :title, :description, :content, :address, :latitude, :longitude, :user_id, :date
  json.url post_url(post, format: :json)
end