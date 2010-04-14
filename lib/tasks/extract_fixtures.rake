namespace :db do
  namespace :fixtures do
    desc 'Create YAML test fixtures from data in an existing database. Load specific fixtures using FIXTURES=x,y. Load specific models using MODELS=x,y
    Defaults to development database. Set RAILS_ENV to override.'
  
    task :extract => :environment do
      def active_record_models
        Dir.glob(File.join(RAILS_ROOT,'app','models','**','*.rb')).each do |file|
          require_dependency file
        end
        classes = ActiveRecord::Base.send(:subclasses)
        classes = classes.map{|c|c if c.table_exists? and !c.table_name['version']}.compact
      end
      classes = active_record_models
      classes += ENV['MODELS'].split(/,/).map(&:constantize) if ENV['MODELS']
      sql = "SELECT * FROM %s ORDER BY %s"
      skip_tables = ["schema_info", "sessions", "schema_migrations"]
      ActiveRecord::Base.establish_connection
      tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables
      tables.each do |table_name|
        i = "000"
        classe = classes.detect{|c|c.table_name == table_name}
        if classe and classe.column_names.include? classe.primary_key
          #require 'yaml'
          class Hash
            # Replacing the to_yaml function so it'll serialize hashes sorted (by their keys)
            #
            # Original function is in /usr/lib/ruby/1.8/yaml/rubytypes.rb
            def to_yaml( opts = {} )
              YAML::quick_emit( object_id, opts ) do |out|
                out.map( taguri, to_yaml_style ) do |map|
                  sort.each do |k, v|   # <-- here's my addition (the 'sort')
                    map.add( k, v )
                  end
                end
              end
            end
          end
          if File.exists? "#{RAILS_ROOT}/test/fixtures/#{table_name}.yml"
            h = YAML.load_file("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml")
          else
            h = {}
          end
          to = {}.respond_to?(:ya2yaml) ? :ya2yaml : :to_yaml
          File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
            data = ActiveRecord::Base.connection.select_all(sql % [table_name, classe.primary_key])
            file.write data.inject({}) { |hash, record|
              id = classe ? record[classe.primary_key] : i.succ!
              if h and classe and name = h.find{|k,v|v[classe.primary_key] == record[classe.primary_key]}
                name = name.first
              else
                name = "#{table_name}_#{id}"
              end
              hash[name] = record
              hash
            }.send to
          end
        end
      end
    end
  end
end
