class Post < ActiveRecord::Base
	belongs_to :user
	default_scope -> { order('created_at DESC') }
	validates :user_id, presence: true
	validates :title, presence: true, length: { maximum: 30 }
	validates :description, presence: true, length: { maximum: 140 }
	geocoded_by :address
	after_validation :geocode
  has_many :post_pictures, dependent: :destroy
  accepts_nested_attributes_for :post_pictures, :allow_destroy => true

end
