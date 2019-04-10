module Alchemy::Custom::Model::Errors
  class ParentNil < Error

    def initialize(msg = nil)
      msg = "You have define parent (use belongs_to method in controller" if msg.nil?
      super(msg)
    end


  end
end