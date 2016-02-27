module Rake
  module Sequel
    module Adapters
      class Postgres
        attr_reader :config

        def initialize(config)
          @config = config
        end

        def console
          command = %w(psql)
          add_connection_settings command
          exec command.join(' ')
        end

        def create
          command = %w(createdb)
          add_connection_settings command
          `#{command.join ' '}`
        end

        def drop
          command = %w(dropdb)
          add_connection_settings command
          `#{command.join ' '}`
        end

        private

        def add_connection_settings(command)
          command << "-U #{config['user']}"
          command << "-W #{config['password']}" unless config['password'].nil?
          command << config['database']
        end
      end
    end
  end
end
