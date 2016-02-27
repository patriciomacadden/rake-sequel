module Rake
  module Sequel
    module Adapters
      def self.create(database_file, environment)
        hash = YAML.load_file database_file
        klass = const_get "Rake::Sequel::Adapters::#{Inflecto.camelize(hash[environment]['adapter'])}"
        klass.new hash[environment]
      end
    end
  end
end
