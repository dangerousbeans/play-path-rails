# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module PlaypathRails
  # HTTP client for PlayPath.io API
  class Client
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    # Items API methods

    # List all items
    def list_items
      request(:get, '/api/items')
    end

    # Get a specific item by ID
    def get_item(id)
      request(:get, "/api/items/#{id}")
    end

    # Create a new item
    def create_item(title:, url: nil, text: nil, tags: [])
      body = { title: title }
      body[:url] = url if url
      body[:text] = text if text
      body[:tags] = tags if tags&.any?

      request(:post, '/api/items', body: body)
    end

    # Update an existing item
    def update_item(id, title: nil, url: nil, text: nil, tags: nil)
      body = {}
      body[:title] = title if title
      body[:url] = url if url
      body[:text] = text if text
      body[:tags] = tags if tags

      request(:patch, "/api/items/#{id}", body: body)
    end

    # Delete an item
    def delete_item(id)
      request(:delete, "/api/items/#{id}")
    end

    # RAG Chat API methods

    # Send a message to the RAG assistant
    def chat(message:, history: [])
      body = { message: message }
      body[:history] = history if history&.any?

      request(:post, '/api/rag/chat', body: body, endpoint_type: :rag)
    end

    private

    def request(method, path, body: nil, endpoint_type: :items)
      uri = URI.join(configuration.base_url, path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      request = build_request(method, uri, body, endpoint_type)
      response = http.request(request)

      handle_response(response)
    end

    def build_request(method, uri, body, endpoint_type)
      request_class = case method
                      when :get then Net::HTTP::Get
                      when :post then Net::HTTP::Post
                      when :patch then Net::HTTP::Patch
                      when :put then Net::HTTP::Put
                      when :delete then Net::HTTP::Delete
                      else raise ArgumentError, "Unsupported HTTP method: #{method}"
                      end

      request = request_class.new(uri)
      request['Content-Type'] = 'application/json'

      # Set authentication header
      api_key = configuration.api_key_for(endpoint_type)
      raise AuthenticationError, 'API key not configured' unless api_key

      request['X-Api-Key'] = api_key

      request.body = JSON.generate(body) if body

      request
    end

    def handle_response(response)
      case response.code.to_i
      when 200, 201
        return nil if response.body.nil? || response.body.empty?

        JSON.parse(response.body)
      when 204
        nil
      when 400
        error_data = parse_error_response(response)
        raise ValidationError.new(error_data[:message], status_code: 400, response_body: response.body)
      when 401
        raise AuthenticationError.new('Unauthorized', status_code: 401, response_body: response.body)
      when 403
        error_data = parse_error_response(response)
        if error_data[:message]&.include?('Trial limit')
          raise TrialLimitError.new(error_data[:message], status_code: 403, response_body: response.body)
        end

        raise APIError.new('Forbidden', status_code: 403, response_body: response.body)

      when 404
        raise NotFoundError.new('Resource not found', status_code: 404, response_body: response.body)
      when 422
        error_data = parse_error_response(response)
        message = error_data[:errors]&.join(', ') || 'Validation failed'
        raise ValidationError.new(message, status_code: 422, response_body: response.body)
      when 429
        raise RateLimitError.new('Rate limit exceeded', status_code: 429, response_body: response.body)
      when 502
        error_data = parse_error_response(response)
        raise ExternalServiceError.new(error_data[:message] || 'Bad Gateway', status_code: 502,
                                                                              response_body: response.body)
      else
        raise APIError.new("HTTP #{response.code}: #{response.message}", status_code: response.code.to_i,
                                                                         response_body: response.body)
      end
    end

    def parse_error_response(response)
      return { message: 'Unknown error' } if response.body.nil? || response.body.empty?

      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError
      { message: response.body }
    end
  end
end
