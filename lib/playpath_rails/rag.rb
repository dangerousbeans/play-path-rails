# frozen_string_literal: true

module PlaypathRails
  # Helper module for RAG (Retrieval-Augmented Generation) functionality
  module RAG
    class << self
      # Send a message to the RAG assistant
      # @param message [String] The user's question or message
      # @param history [Array] Optional array of previous conversation messages
      # @return [Hash] Response containing reply, usage, and limit information
      def chat(message:, history: [])
        PlaypathRails.client.chat(message: message, history: history)
      end

      # Send a simple message without conversation history
      # @param message [String] The user's question or message
      # @return [String] The AI-generated response
      def ask(message)
        response = chat(message: message)
        response['reply']
      end

      # Build a conversation history array from alternating user/assistant messages
      # @param messages [Array] Array of message strings, alternating user/assistant
      # @return [Array] Properly formatted history array
      def build_history(*messages)
        history = []
        messages.each_with_index do |message, index|
          role = index.even? ? 'user' : 'assistant'
          history << { 'role' => role, 'text' => message }
        end
        history
      end
    end
  end
end
