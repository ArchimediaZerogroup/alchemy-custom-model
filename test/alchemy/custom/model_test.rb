require 'test_helper'

class Alchemy::Custom::Model::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Alchemy::Custom::Model
  end
end
