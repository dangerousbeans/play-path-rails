# Controller Integration Guide

This guide shows how to integrate PlaypathRails with your Rails controllers to manage items in your Playpath workspace.

## Basic Setup

First, ensure you have configured PlaypathRails in your application:

```ruby
# config/initializers/playpath_rails.rb
PlaypathRails.configure do |config|
  config.api_key = ENV['PLAYPATH_API_KEY']
  config.embeddings_api_key = ENV['PLAYPATH_EMBEDDINGS_API_KEY'] # Optional, for RAG features
  config.base_url = 'https://api.playpath.ai' # Default
end
```

## Controller Example

See `examples/items_controller_example.rb` for a complete controller implementation that demonstrates:

- Listing items from Playpath
- Creating new items
- Updating existing items
- Deleting items
- Proper parameter handling for both nested and flat parameter structures

## Parameter Handling

The controller example shows how to handle both parameter formats:

### Nested Parameters
```ruby
# When parameters come as: { item: { title: "...", url: "...", text: "...", tags: [...] } }
params.require(:item).permit(:title, :url, :text, tags: [])
```

### Flat Parameters
```ruby
# When parameters come as: { title: "...", url: "...", text: "...", tags: [...] }
params.permit(:title, :url, :text, tags: [])
```

## Available Client Methods

The PlaypathRails client provides the following methods:

- `PlaypathRails.client.list_items` - Get all items
- `PlaypathRails.client.get_item(id)` - Get a specific item
- `PlaypathRails.client.create_item(params)` - Create a new item
- `PlaypathRails.client.update_item(id, params)` - Update an existing item
- `PlaypathRails.client.delete_item(id)` - Delete an item

## Error Handling

The client will raise `PlaypathRails::AuthenticationError` if no API key is configured. Make sure to handle this appropriately in your application.

## RAG Features

If you have configured an embeddings API key, you can also use the RAG chat features:

```ruby
# Simple chat
response = PlaypathRails::RAG.ask("What items do I have about Ruby?")

# Chat with history
history = ["Previous question", "Previous response"]
response = PlaypathRails::RAG.chat("Follow-up question", history: history)