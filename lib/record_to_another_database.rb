if DatabaseSwitcher.record?
  module ActiveRecord
    class Base
      def self.inherited(child) #:nodoc:
        @@subclasses[self] ||= []
        @@subclasses[self] << child
        self.class_eval do
          include SaveToAnotherDatabase
          def after_find
            self.save_to DatabaseSwitcher.record_to
          end
        end
        super
      end
    end
  end
end