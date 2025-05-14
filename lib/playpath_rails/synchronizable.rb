# frozen_string_literal: true

require 'active_support/concern'

module PlaypathRails
  # Module to add synchronization callbacks and methods to ActiveRecord models
  module Synchronizable
    extend ActiveSupport::Concern

    included do
      # Only add callbacks if the host class supports them
      if respond_to?(:after_commit)
        after_commit :playpath_sync!, on: [:create, :update]
      end
      if respond_to?(:before_destroy)
        before_destroy :playpath_delete!
      end
    end

    class_methods do
      # Declare that this model should be synced to PlayPath.io
      # options:
      #   only: Array of symbols specifying which fields to sync
      #   index: String name of the index to use
      def playpath_sync(only: nil, index: nil)
        @playpath_sync_options = { only: only, index: index }
      end

      # Retrieve synchronization options for this model
      def playpath_sync_options
        @playpath_sync_options || {}
      end
    end

    # Push current record state to PlayPath.io
    def playpath_sync!
      # Implementation to integrate with PlayPath.io API goes here
      # This is a stub for now
      true
    end

    # Remove record from PlayPath.io index
    def playpath_delete!
      # Implementation to integrate with PlayPath.io API goes here
      # This is a stub for now
      true
    end
  end
end