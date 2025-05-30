# frozen_string_literal: true

begin
  require 'rails/railtie'
rescue LoadError
  # Rails not available, skip railtie
  return
end

module PlaypathRails
  class Railtie < Rails::Railtie
    generators do
      require 'generators/playpath_rails/migration_generator'
    rescue LoadError
      # Generator not found, log warning but don't fail
      # Rails.logger&.warn("PlaypathRails generator could not be loaded: #{e.message}")
    end
  end
end
