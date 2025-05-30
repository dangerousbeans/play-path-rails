# frozen_string_literal: true

require_relative 'playpath_rails/version'
require_relative 'playpath_rails/errors'
require_relative 'playpath_rails/client'
require_relative 'playpath_rails/synchronizable'
require_relative 'playpath_rails/rag'

# Load railtie if Rails is available
begin
  require_relative 'playpath_rails/railtie' if defined?(Rails::Railtie)
rescue LoadError
  # Silently ignore if Rails is not available
end

module PlaypathRails
  class Error < StandardError; end

  class << self
    # Accessor for global configuration
    attr_accessor :configuration

    # Configure PlaypathRails with API credentials and settings
    # Usage:
    #   PlaypathRails.configure do |config|
    #     config.api_key = 'KEY'
    #     config.embeddings_api_key = 'EMBEDDINGS_KEY'
    #     config.base_url = 'https://custom-url'
    #   end
    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    # Get a configured client instance
    def client
      @client ||= Client.new(configuration)
    end
  end

  # Configuration object for PlaypathRails
  class Configuration
    # Regular API key for PlayPath.io (full access)
    attr_accessor :api_key
    # Embeddings API key for PlayPath.io (limited to RAG endpoints)
    attr_accessor :embeddings_api_key
    # Base URL for API requests (defaults to Playpath.io service)
    attr_accessor :base_url

    def initialize
      @api_key = nil
      @embeddings_api_key = nil
      @base_url = 'https://playpath.io'
    end

    # Get the appropriate API key for the request type
    def api_key_for(endpoint_type = :items)
      case endpoint_type
      when :rag
        @embeddings_api_key || @api_key
      else
        @api_key
      end
    end
  end
end
