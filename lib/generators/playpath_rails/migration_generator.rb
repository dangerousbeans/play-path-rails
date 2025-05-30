# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module PlaypathRails
  module Generators
    class MigrationGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      argument :model_name, type: :string, desc: 'The model to add PlayPath synchronization to'

      def create_migration_file
        migration_template 'add_playpath_item_id_migration.rb.erb',
                           "db/migrate/add_playpath_item_id_to_#{table_name}.rb"
      end

      private

      def table_name
        model_name.tableize
      end

      def migration_class_name
        "AddPlaypathItemIdTo#{model_name.camelize.pluralize}"
      end
    end
  end
end
