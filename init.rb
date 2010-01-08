# Include hook code here
ARGV.each do |arg|
  if arg =~ /^(\w+)=(.*)$/ and $1 == 'RECORDER'
    require 'database_switcher'
    def DatabaseSwitcher.record?
      true
    end
    DatabaseSwitcher.class_eval do
      def self.record_to
        ActiveRecord::Base.configurations['test']['database']
      end
      @database = $2
    end
    def DatabaseSwitcher.record_from
      @database
    end
    require 'record_to_another_database'
  end
end
