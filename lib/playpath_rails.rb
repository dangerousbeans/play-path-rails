# frozen_string_literal: true

require_relative "playpath_rails/version"
require_relative "playpath_rails/synchronizable"

module PlaypathRails
  class Error < StandardError; end

  class << self
    # Accessor for global configuration
    attr_accessor :configuration

    # Configure PlaypathRails with API credentials and settings
    # Usage:
    #   PlaypathRails.configure do |config|
    #     config.api_key = 'KEY'
    #     config.base_url = 'https://custom-url'
    #   end
    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end
  end

  # Configuration object for PlaypathRails
  class Configuration
    # API key for PlayPath.io
    attr_accessor :api_key
    # Base URL for API requests (defaults to Playpath.io service)
    attr_accessor :base_url

    def initialize
      @api_key = nil
      @base_url = "https://api.playpath.io"
    end
  end
end
