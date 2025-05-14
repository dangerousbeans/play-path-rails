<!--- @ playpath_rails README -->
# PlaypathRails

A Ruby on Rails gem that extends ActiveRecord to enable synchronization between your application data and the PlayPath.io Retrieval-Augmented Generation (RAG) service. With PlaypathRails, you can automatically keep your database records in sync with PlayPath's Items API for powerful retrieval and search capabilities.

[![Gem Version](https://badge.fury.io/rb/playpath_rails.svg)](https://badge.fury.io/rb/playpath_rails) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- Seamless integration with ActiveRecord models
- Automatic synchronization of create, update, and destroy events
- Configurable indexing strategies
- Support for custom field mappings

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

Before using PlaypathRails, you need to configure your API credentials and any optional settings. Create an initializer at `config/initializers/playpath_rails.rb`:

```ruby
PlaypathRails.configure do |config|
  config.api_key = Rails.application.credentials.playpath[:api_key] || ENV['PLAYPATH_API_KEY']
  # Optionally customize the base URL (defaults to https://api.playpath.io)
  # config.base_url = 'https://custom-api.playpath.io'
end
```

## Usage

Include the `Synchronizable` module in any ActiveRecord model you wish to sync:

```ruby
class Article < ApplicationRecord
  include PlaypathRails::Synchronizable

  # Automatically sync all attributes on create/update/destroy
  playpath_sync

  # Or customize fields and index name:
  # playpath_sync only: %i[title content], index: 'articles_index'
end
```

Once configured, saving, updating, or destroying records will automatically propagate changes to your PlayPath.io account.

You can also manually trigger synchronization:

```ruby
article = Article.find(1)
article.playpath_sync!   # Push current state
article.playpath_delete! # Remove from PlayPath index
```

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