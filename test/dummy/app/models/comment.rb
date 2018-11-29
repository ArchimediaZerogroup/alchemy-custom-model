# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  author      :string
#  description :text
#  file_id     :integer
#  post_id     :integer
#  language_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Comment < ApplicationRecord
  include Alchemy::Custom::Model::ModelDecoration

  belongs_to :file, class_name: "Alchemy::Attachment", optional: true, foreign_key: :file_id
  global_id_setter :file

  belongs_to :post

  has_many :comment_pictures, dependent: :destroy
  accepts_nested_attributes_for :comment_pictures


end
