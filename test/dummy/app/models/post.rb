class Post < ApplicationRecord

  include Alchemy::Custom::Model::ModelDecoration

  belongs_to :file, class_name: "Alchemy::Attachment", optional: true, foreign_key: :file_id
  global_id_setter :file

  belongs_to :picture, class_name: 'Alchemy::Picture', optional: true, touch: true
  global_id_setter :picture


end
