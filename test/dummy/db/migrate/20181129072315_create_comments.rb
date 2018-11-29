class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.string :author
      t.text :description
      t.integer :file_id
      t.integer :post_id
      t.integer :language_id

      t.timestamps
    end
  end
end
