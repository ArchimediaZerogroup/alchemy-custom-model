class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :name
      t.integer :picture_id
      t.integer :file_id
      t.integer :language_id

      t.timestamps
    end
  end
end
