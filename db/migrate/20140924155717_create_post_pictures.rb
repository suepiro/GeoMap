class CreatePostPictures < ActiveRecord::Migration
  def change
    create_table :post_pictures do |t|
      t.integer :post_id
      t.string :image

      t.timestamps
    end
  end
end
