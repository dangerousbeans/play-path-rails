#!/usr/bin/env ruby
# frozen_string_literal: true

# Example usage of PlaypathRails gem
require_relative '../lib/playpath_rails'

# Configure the gem
PlaypathRails.configure do |config|
  config.api_key = ENV['PLAYPATH_API_KEY'] || 'your_api_key_here'
  config.embeddings_api_key = ENV['PLAYPATH_EMBEDDINGS_KEY'] # Optional
  config.base_url = 'https://playpath.io'
end

puts "PlaypathRails Example Usage"
puts "=" * 40

# Example 1: Direct API usage
puts "\n1. Direct API Usage:"
begin
  client = PlaypathRails.client
  
  # Create an item
  puts "Creating an item..."
  item = client.create_item(
    title: "Ruby Programming Basics",
    url: "https://example.com/ruby-basics",
    text: "Learn the fundamentals of Ruby programming language",
    tags: ["ruby", "programming", "tutorial"]
  )
  puts "Created item: #{item['title']} (ID: #{item['id']})"
  
  # List items
  puts "\nListing items..."
  items = client.list_items
  puts "Found #{items.length} items"
  
rescue PlaypathRails::AuthenticationError
  puts "Error: Please configure a valid API key"
rescue PlaypathRails::APIError => e
  puts "API Error: #{e.message}"
end

# Example 2: RAG Chat usage
puts "\n2. RAG Chat Usage:"
begin
  # Simple question
  puts "Asking a simple question..."
  response = PlaypathRails::RAG.ask("What is Ruby programming?")
  puts "Response: #{response}"
  
  # Chat with history
  puts "\nChat with conversation history..."
  history = PlaypathRails::RAG.build_history(
    "What is Ruby?",
    "Ruby is a dynamic programming language...",
    "What are its main features?"
  )
  
  result = PlaypathRails::RAG.chat(
    message: "Can you give me some examples?",
    history: history
  )
  puts "Response: #{result['reply']}"
  puts "Usage: #{result['usage']}/#{result['limit']}" if result['usage']
  
rescue PlaypathRails::AuthenticationError
  puts "Error: Please configure a valid API key"
rescue PlaypathRails::TrialLimitError
  puts "Error: Trial limit exceeded"
rescue PlaypathRails::APIError => e
  puts "API Error: #{e.message}"
end

# Example 3: Model synchronization (simulated)
puts "\n3. Model Synchronization Example:"
puts "In a Rails application, you would include the Synchronizable module:"
puts <<~RUBY
  class Article < ApplicationRecord
    include PlaypathRails::Synchronizable
    
    # Configure synchronization
    playpath_sync(
      title_field: :title,
      text_field: :content,
      url_field: :permalink,
      tags_field: :tag_list,
      tags: ['article', 'blog']
    )
  end
  
  # Then create/update records normally:
  article = Article.create!(
    title: "My Blog Post",
    content: "This is the content...",
    permalink: "https://myblog.com/my-post",
    tag_list: ["ruby", "rails"]
  )
  
  # The record will be automatically synced to PlayPath.io
  # You can also manually sync:
  article.sync_to_playpath!
RUBY

puts "\nExample completed!"