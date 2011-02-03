class Book < ActiveRecord::Base
  
  def read!
    self.update_attribute(:read_count, (read_count + 1))
  end
  
end
