module Rake
  module Sequel
    module Adapters
      class Sqlite
        attr_reader :config

        def initialize(config)
          @config = config
        end

        def console
          command = %w(sqlite3)
          add_connection_settings command
          exec command.join(' ')
        end

        def create
          nil
        end

        def drop
          nil
        end

        private

        def add_connection_settings(command)
          command << config['database']
        end
      end
    end
  end
end
