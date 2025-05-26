# frozen_string_literal: true

module PlaypathRails
  # Base error class for PlaypathRails
  class Error < StandardError; end

  # Authentication error
  class AuthenticationError < Error; end

  # API request error
  class APIError < Error
    attr_reader :status_code, :response_body

    def initialize(message, status_code: nil, response_body: nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  # Validation error from API
  class ValidationError < APIError; end

  # Trial limit exceeded error
  class TrialLimitError < APIError; end

  # Resource not found error
  class NotFoundError < APIError; end

  # Rate limit exceeded error
  class RateLimitError < APIError; end

  # External service error (e.g., OpenAI API)
  class ExternalServiceError < APIError; end
end
