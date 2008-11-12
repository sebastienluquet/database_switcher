require 'database_switcher'
class ActiveRecord::Base
  def save_to database = 'test'
    old = ActiveRecord::Base.connection.connection_options[3]
    switch_database database
    if self.class.find_by_id(self.id).nil?
      r = self.clone
      r.id = self.id
      r.save
    end
    switch_database old
  end
end
