class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :description
      t.text :content
      t.string :address
      t.float :latitude
      t.float :longitude
      t.integer :user_id
      t.datetime :date

      t.timestamps
    end
    add_index :posts, [:user_id, :created_at]
  end
end
