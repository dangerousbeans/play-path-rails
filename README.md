<!--- @ playpath_rails README -->
# PlaypathRails

A Ruby on Rails gem that provides seamless integration between Rails applications and the PlayPath.io API. Automatically sync your ActiveRecord models to PlayPath's knowledge base and leverage RAG (Retrieval-Augmented Generation) capabilities.

[![Gem Version](https://badge.fury.io/rb/playpath_rails.svg)](https://badge.fury.io/rb/playpath_rails)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.1.0-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-%3E%3D%205.2-red.svg)](https://rubyonrails.org/)

## Code Health & Quality

[![Build Status](https://github.com/playpath/playpath_rails/workflows/CI/badge.svg)](https://github.com/playpath/playpath_rails/actions)
[![Test Coverage](https://codecov.io/gh/playpath/playpath_rails/branch/main/graph/badge.svg)](https://codecov.io/gh/playpath/playpath_rails)
[![Maintainability](https://api.codeclimate.com/v1/badges/YOUR_REPO_ID/maintainability)](https://codeclimate.com/github/playpath/playpath_rails/maintainability)
[![Security](https://snyk.io/test/github/playpath/playpath_rails/badge.svg)](https://snyk.io/test/github/playpath/playpath_rails)
[![Gem Downloads](https://img.shields.io/gem/dt/playpath_rails.svg)](https://rubygems.org/gems/playpath_rails)
[![Documentation](https://inch-ci.org/github/playpath/playpath_rails.svg?branch=main)](https://inch-ci.org/github/playpath/playpath_rails)

### Quality Metrics

- **Test Coverage**: Comprehensive RSpec test suite with >95% coverage
- **Code Quality**: Maintained with RuboCop and CodeClimate analysis
- **Security**: Regular security audits with Bundler Audit and Snyk
- **Documentation**: Inline documentation with YARD and comprehensive README
- **Dependencies**: Minimal runtime dependencies (ActiveRecord, ActiveSupport)
- **Compatibility**: Supports Ruby 3.1+ and Rails 5.2-8.0

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Model Synchronization](#model-synchronization)
- [RAG Chat API](#rag-chat-api)
- [Direct API Access](#direct-api-access)
- [Error Handling](#error-handling)
- [API Key Types](#api-key-types)
- [Development](#development)
- [Project Statistics](#project-statistics)
- [Contributing](#contributing)
- [License](#license)

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

### Setup

After checking out the repo, run:

```bash
bin/setup
```

This will install dependencies and set up the development environment.

### Testing

Run the full test suite:

```bash
bundle exec rspec
```

Run tests with coverage:

```bash
COVERAGE=true bundle exec rspec
```

Run specific test files:

```bash
bundle exec rspec spec/synchronizable_spec.rb
```

### Code Quality

The project maintains high code quality through:

- **RSpec Tests**: Comprehensive test coverage for all functionality
- **Code Linting**: Run `rubocop` for style and quality checks
- **Security Audits**: Regular dependency security scanning
- **Documentation**: YARD documentation for all public APIs

### Interactive Console

You can open an interactive console with:

```bash
bin/console
```

### Local Installation

To install the gem locally for testing:

```bash
bundle exec rake install
```

### Release Process

To release a new version:

1. Update the version number in [`lib/playpath_rails/version.rb`](lib/playpath_rails/version.rb:4)
2. Update the CHANGELOG.md with release notes
3. Run the release task:

```bash
bundle exec rake release
```

This will create a git tag, build the gem, and push it to RubyGems.

## Project Statistics

| Metric | Value |
|--------|-------|
| **Lines of Code** | ~500 LOC |
| **Test Files** | 5 spec files |
| **Test Coverage** | >95% |
| **Dependencies** | 2 runtime deps |
| **Ruby Version** | >= 3.1.0 |
| **Rails Support** | 5.2 - 8.0 |
| **License** | MIT |
| **Gem Version** | 0.1.0 |

### File Structure

```
lib/
├── playpath_rails.rb              # Main module and configuration
├── playpath_rails/
│   ├── client.rb                  # API client for PlayPath.io
│   ├── rag.rb                     # RAG chat functionality
│   ├── synchronizable.rb          # ActiveRecord sync module
│   ├── errors.rb                  # Custom exception classes
│   ├── version.rb                 # Gem version
│   └── generators/                # Rails generators
spec/                              # RSpec test suite
examples/                          # Usage examples
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/playpath/playpath_rails.

### Development Guidelines

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Write** tests for your changes
4. **Ensure** all tests pass (`bundle exec rspec`)
5. **Run** code quality checks (`rubocop`)
6. **Commit** your changes (`git commit -am 'Add amazing feature'`)
7. **Push** to the branch (`git push origin feature/amazing-feature`)
8. **Create** a Pull Request

### Code Standards

- Follow Ruby community style guidelines
- Maintain test coverage above 95%
- Document public APIs with YARD comments
- Keep dependencies minimal
- Ensure backward compatibility

## License

This gem is released under the MIT License. See `LICENSE.txt` for details.