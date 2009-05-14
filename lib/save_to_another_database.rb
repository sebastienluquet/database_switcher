require 'database_switcher'
module SaveToAnotherDatabase
  def save_to database = 'test'
    old = ActiveRecord::Base.connection.connection_options[3]
    switch_database database
    if DatabaseSwitcher.record?
      self.class.module_eval do
        def after_find
          self
        end
      end
    end
    if (r = self.class.send("find_by_#{self.class.primary_key}", self.id)).nil?
      r = self.clone
      r.id = self.id
      r.skip_callbacks = true
      r.save(false)
    end
    if DatabaseSwitcher.record?
      self.class.module_eval do
        def after_find
          super
        end
      end
    end
    switch_database old
    r
  end
end
