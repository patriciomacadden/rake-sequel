require "inflecto"
require "rake"
require "rake/tasklib"
require "yaml"
require "sequel"

require "rake/sequel/adapters"
require "rake/sequel/adapters/postgres"
require "rake/sequel/adapters/sqlite"
require "rake/sequel/version"

module Rake
  class SequelTask < Rake::TaskLib
    attr_accessor :database_file, :migrations_dir, :seeds_file
    attr_reader :environment

    def initialize
      @database_file = File.join Dir.pwd, "config", "database.yml"
      @environment = ENV.fetch 'RACK_ENV', 'development'
      @migrations_dir = File.join Dir.pwd, "db", "migrate"
      @seeds_file = File.join Dir.pwd, "db", "seeds.rb"

      yield self if block_given?

      define
    end

    def adapter
      @adapter ||= Rake::Sequel::Adapters.create database_file, environment
    end

    def db_connection
      hash = YAML.load_file database_file
      db = ::Sequel.connect hash[environment]
    end

    def define
      namespace :db do
        desc "Starts a database console"
        task :console do
          adapter.console
        end
        task c: :console

        desc "Creates the database"
        task :create do
          adapter.create
        end

        desc "Drops the database"
        task :drop do
          adapter.drop
        end

        desc "Runs database migrations"
        task :migrate, [:version] do |t, args|
          ::Sequel.extension :migration

          if args[:version]
            ::Sequel::Migrator.run db_connection, migrations_dir, target: args[:version].to_i
          else
            ::Sequel::Migrator.run db_connection, migrations_dir
          end
        end

        desc "Resets the database"
        task reset: %w(db:drop db:create db:migrate)

        desc "Rolls back one migration"
        task :rollback, [:version] do |t, args|
          ::Sequel.extension :migration

          migrator = ::Sequel::Migrator.migrator_class(migrations_dir).new(db_connection, migrations_dir)

          version = args[:version].nil? ? migrator.current - 1 : args[:version].to_i

          Rake::Task['db:migrate'].execute version: version
        end

        desc "Populates the database"
        task :seed do
          require seeds_file
        end
      end
    end
  end
end
