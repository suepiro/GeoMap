class Post < ActiveRecord::Base
	belongs_to :user
	validates :description, length: { maximum: 140 }
	geocoded_by :address
	after_validation :geocode
end
