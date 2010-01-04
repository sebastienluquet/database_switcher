# Include hook code here
ARGV.each do |arg|
  if arg =~ /^(\w+)=(.*)$/ and $1 == 'RECORDER'
    require 'database_switcher'
    DatabaseSwitcher
    def DatabaseSwitcher.record?
      true
    end
    DatabaseSwitcher.class_eval do
      def self.record_to
        $2
      end
    end
    require 'record_to_another_database'
  end
end
