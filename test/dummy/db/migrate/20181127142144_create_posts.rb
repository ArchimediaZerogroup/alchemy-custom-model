class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :name
      t.integer :picture_id
      t.integer :file_id
      t.integer :language_id
      t.text :description
      t.string :slug
      t.text :meta_description
      t.text :meta_keywords
      t.string :meta_title
      t.boolean :robot_follow
      t.boolean :robot_index

      t.timestamps
    end

    add_index :posts, :slug, unique: true

  end
end
