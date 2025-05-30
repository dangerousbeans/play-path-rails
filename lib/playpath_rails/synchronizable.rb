# frozen_string_literal: true

require 'active_support/concern'

module PlaypathRails
  # Module to add synchronization callbacks and methods to ActiveRecord models
  module Synchronizable
    extend ActiveSupport::Concern

    included do
      # Only add callbacks if the host class supports them
      after_commit :playpath_sync!, on: %i[create update] if respond_to?(:after_commit)
      before_destroy :playpath_delete! if respond_to?(:before_destroy)
    end

    class_methods do
      # Declare that this model should be synced to PlayPath.io
      # options:
      #   only: Array of symbols specifying which fields to sync
      #   title_field: Symbol specifying which field to use as the title (required)
      #   url_field: Symbol specifying which field to use as the URL (optional)
      #   text_field: Symbol specifying which field to use as the text content (optional)
      #   tags_field: Symbol specifying which field contains tags (optional)
      #   tags: Array of static tags to apply to all items (optional)
      def playpath_sync(only: nil, title_field: :title, url_field: nil, text_field: nil, tags_field: nil, tags: [])
        @playpath_sync_options = {
          only: only,
          title_field: title_field,
          url_field: url_field,
          text_field: text_field,
          tags_field: tags_field,
          tags: tags
        }
      end

      # Retrieve synchronization options for this model
      def playpath_sync_options
        @playpath_sync_options || { title_field: :title }
      end
    end

    # Push current record state to PlayPath.io
    def playpath_sync!
      return true unless should_sync?

      begin
        item_data = build_item_data

        if playpath_item_id && playpath_item_id != 0
          # Update existing item
          PlaypathRails.client.update_item(playpath_item_id, **item_data)
        else
          # Create new item
          response = PlaypathRails.client.create_item(**item_data)
          # Store the item ID if the model supports it
          update_column(:playpath_item_id, response['id']) if respond_to?(:playpath_item_id=) && response&.dig('id')
        end

        true
      rescue PlaypathRails::Error => e
        # Log the error but don't raise it to avoid breaking the application
        # Rails.logger.error("PlayPath sync failed for #{self.class.name}##{id}: #{e.message}") if defined?(Rails)
        false
      end
    end

    # Remove record from PlayPath.io
    def playpath_delete!
      return true unless playpath_item_id && playpath_item_id != 0

      begin
        PlaypathRails.client.delete_item(playpath_item_id)
        true
      rescue PlaypathRails::NotFoundError
        # Item already deleted, consider this success
        true
      rescue PlaypathRails::Error => e
        # Log the error but don't raise it to avoid breaking the application
        # Rails.logger.error("PlayPath delete failed for #{self.class.name}##{id}: #{e.message}") if defined?(Rails)
        false
      end
    end

    # Manually sync this record to PlayPath.io (bypasses callbacks)
    def sync_to_playpath!
      playpath_sync!
    end

    # Get the PlayPath item ID for this record
    def playpath_item_id
      return nil unless respond_to?(:playpath_item_id)

      read_attribute(:playpath_item_id)
    end

    private

    def should_sync?
      # Check if PlayPath is configured
      return false unless PlaypathRails.configuration&.api_key

      # Check if the record has the required title field
      options = self.class.playpath_sync_options
      title_field = options[:title_field]
      title_value = respond_to?(title_field) ? send(title_field) : nil
      return false unless title_value && !title_value.to_s.empty?

      # If 'only' fields are specified, check if any of them changed
      return options[:only].any? { |field| saved_change_to_attribute?(field) } if options[:only]&.any?

      true
    end

    def build_item_data
      options = self.class.playpath_sync_options
      data = {}

      # Title is required
      title_field = options[:title_field]
      data[:title] = send(title_field).to_s if respond_to?(title_field)

      # URL is optional
      if options[:url_field] && respond_to?(options[:url_field])
        url_value = send(options[:url_field])
        data[:url] = url_value.to_s if url_value && !url_value.to_s.empty?
      end

      # Text content is optional
      if options[:text_field] && respond_to?(options[:text_field])
        text_value = send(options[:text_field])
        data[:text] = text_value.to_s if text_value && !text_value.to_s.empty?
      end

      # Tags handling
      tags = []

      # Add static tags
      tags.concat(options[:tags]) if options[:tags]&.any?

      # Add dynamic tags from field
      if options[:tags_field] && respond_to?(options[:tags_field])
        field_tags = send(options[:tags_field])
        case field_tags
        when Array
          tags.concat(field_tags.map(&:to_s))
        when String
          # Assume comma-separated tags
          tags.concat(field_tags.split(',').map(&:strip))
        end
      end

      data[:tags] = tags.uniq if tags.any?

      data
    end
  end
end
