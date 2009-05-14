# Include hook code here
ARGV.each do |arg|
  if arg =~ /^(\w+)=(.*)$/ and $1 == 'RECORDER'
    require 'database_switcher'
    DatabaseSwitcher
    def DatabaseSwitcher.record?
      true
    end
    def DatabaseSwitcher.record_to
      #$2
    end
    require 'record_to_another_database'
  end
end
