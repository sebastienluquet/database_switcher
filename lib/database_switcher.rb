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
    :host     => option[0]
  )
end