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

require 'test_helper'

class CommentPictureTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
