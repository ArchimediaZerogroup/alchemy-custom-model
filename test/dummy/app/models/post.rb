# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  name        :string
#  picture_id  :integer
#  file_id     :integer
#  language_id :integer
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Post < ApplicationRecord

  include Alchemy::Custom::Model::ModelDecoration

  belongs_to :file, class_name: "Alchemy::Attachment", optional: true, foreign_key: :file_id
  global_id_setter :file

  belongs_to :picture, class_name: 'Alchemy::Picture', optional: true, touch: true
  global_id_setter :picture

  has_many :comments, dependent: :destroy
  accepts_nested_attributes_for :comments, allow_destroy: true, reject_if: :all_blank


end
