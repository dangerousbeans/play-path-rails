<!--- @ playpath_rails README -->
# PlaypathRails

A Ruby on Rails gem that provides seamless integration between Rails applications and the PlayPath.io API. Automatically sync your ActiveRecord models to PlayPath's knowledge base and leverage RAG (Retrieval-Augmented Generation) capabilities.

[![Gem Version](https://badge.fury.io/rb/playpath_rails.svg)](https://badge.fury.io/rb/playpath_rails) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **Automatic Model Synchronization**: Sync ActiveRecord models to PlayPath.io Items API
- **RAG Chat Integration**: Query your knowledge base using AI-powered chat
- **Flexible Configuration**: Support for both regular and embeddings-only API keys
- **Error Handling**: Comprehensive error handling with specific exception types
- **Rails Generators**: Easy setup with migration generators

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'playpath_rails'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install playpath_rails
```

## Configuration

Configure PlaypathRails in an initializer (e.g., `config/initializers/playpath_rails.rb`):

```ruby
PlaypathRails.configure do |config|
  config.api_key = ENV['PLAYPATH_API_KEY']                    # Full access API key
  config.embeddings_api_key = ENV['PLAYPATH_EMBEDDINGS_KEY']  # Optional: RAG-only key
  config.base_url = 'https://playpath.io'                     # Optional: custom base URL
end
```

## Model Synchronization

### Basic Setup

1. Add the `playpath_item_id` column to your model:

```bash
rails generate playpath_rails:migration Article
rails db:migrate
```

2. Include the `Synchronizable` module in your model:

```ruby
class Article < ApplicationRecord
  include PlaypathRails::Synchronizable
  
  # Configure synchronization
  playpath_sync(
    title_field: :title,        # Required: field to use as title
    text_field: :content,       # Optional: field to use as text content
    url_field: :permalink,      # Optional: field to use as URL
    tags_field: :tag_list,      # Optional: field containing tags
    tags: ['article', 'blog']   # Optional: static tags to apply
  )
end
```

### Synchronization Options

- `title_field`: The field to use as the item title (required, defaults to `:title`)
- `text_field`: The field to use as the item text content (optional)
- `url_field`: The field to use as the item URL (optional)
- `tags_field`: The field containing tags (can be Array or comma-separated String)
- `tags`: Static tags to apply to all items (Array)
- `only`: Array of fields that trigger sync when changed (optional)

### Manual Synchronization

```ruby
# Manually sync a record
article.sync_to_playpath!

# Check if a record is synced
article.playpath_item_id.present?
```

## RAG Chat API

### Simple Usage

```ruby
# Ask a simple question
response = PlaypathRails::RAG.ask("What is rugby coaching?")
puts response

# Get detailed response with usage info
result = PlaypathRails::RAG.chat(message: "How do I improve my scrum technique?")
puts result['reply']
puts "Usage: #{result['usage']}/#{result['limit']}" if result['usage']
```

### Conversation History

```ruby
# Build conversation history
history = PlaypathRails::RAG.build_history(
  "What is rugby?",
  "Rugby is a team sport...",
  "How many players are on a team?"
)

# Continue conversation
response = PlaypathRails::RAG.chat(
  message: "What about the rules?",
  history: history
)
```

## Direct API Access

### Items API

```ruby
client = PlaypathRails.client

# List all items
items = client.list_items

# Get specific item
item = client.get_item(123)

# Create new item
item = client.create_item(
  title: "Rugby Basics",
  url: "https://example.com/rugby",
  text: "Learn the fundamentals of rugby",
  tags: ["rugby", "sports", "basics"]
)

# Update item
client.update_item(123, title: "Updated Title")

# Delete item
client.delete_item(123)
```

### RAG Chat API

```ruby
# Chat with conversation history
response = client.chat(
  message: "What is rugby coaching?",
  history: [
    { role: "user", text: "Tell me about rugby" },
    { role: "assistant", text: "Rugby is a contact sport..." }
  ]
)
```

## Error Handling

The gem provides specific exception types for different error scenarios:

```ruby
begin
  PlaypathRails::RAG.ask("What is rugby?")
rescue PlaypathRails::AuthenticationError
  # Invalid or missing API key
rescue PlaypathRails::TrialLimitError
  # Free plan limit exceeded
rescue PlaypathRails::ValidationError => e
  # Invalid request data
  puts e.message
rescue PlaypathRails::APIError => e
  # General API error
  puts "API Error: #{e.message} (Status: #{e.status_code})"
end
```

## API Key Types

- **Regular API Key** (`api_key`): Full access to all endpoints
- **Embeddings API Key** (`embeddings_api_key`): Limited access, only works with RAG endpoints

The gem automatically uses the appropriate key based on the endpoint being accessed.

## Development

After checking out the repo, run:

```bash
bin/setup
```

This will install dependencies. Then run the tests:

```bash
bundle exec rspec
```

You can open an interactive console with:

```bash
bin/console
```

To install the gem locally:

```bash
bundle exec rake install
```

To release a new version, update the version number in `lib/playpath_rails/version.rb`, then run:

```bash
bundle exec rake release
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/playpath/playpath_rails.

## License

This gem is released under the MIT License. See `LICENSE.txt` for details.