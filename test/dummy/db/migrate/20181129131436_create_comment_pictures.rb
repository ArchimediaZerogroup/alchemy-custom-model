class CreateCommentPictures < ActiveRecord::Migration[5.2]
  def change
    create_table :comment_pictures do |t|
      t.integer :comment_id
      t.integer :picture_id
      t.integer :position

      t.timestamps
    end
  end
end
