# == Schema Information
#
# Table name: comment_pictures
#
#  id         :integer          not null, primary key
#  comment_id :integer
#  picture_id :integer
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CommentPicture < ApplicationRecord

  belongs_to :comment

  belongs_to :picture, class_name: 'Alchemy::Picture', touch: true
  #relazione generica per i files utilizzata nel volume di elfinder
  belongs_to :alchemy_file_instance, class_name: 'Alchemy::Picture', foreign_key: :picture_id

end
