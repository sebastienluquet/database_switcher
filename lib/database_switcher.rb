class ActiveRecord::ConnectionAdapters::AbstractAdapter  
  attr_reader :connection_options
end

def switch_database database
  option = ActiveRecord::Base.connection.connection_options
  ActiveRecord::Base.establish_connection(
    :adapter  => 'mysql',
    :database => "#{database}",
    :username => option[1],
    :password => option[2],
    :encoding => 'utf8',
    :host     => option[0]
  )
end

module DatabaseSwitcher
  attr_accessor :database

  def self.record?
    false
  end

  def use_database database
    @database = database
    include UseRecetteDataBase
  end

  module UseRecetteDataBase
    def setup_fixtures
      @old_database = ActiveRecord::Base.connection.connection_options[3]
      switch_database(self.class.database)
      super
    end
    def teardown_fixtures
      super
      switch_database(@old_database)
    end
  end
end