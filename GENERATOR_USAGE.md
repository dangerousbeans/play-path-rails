# PlaypathRails Generator Usage

## Rails Migration Generator

The PlaypathRails gem includes a Rails generator to easily add the required `playpath_item_id` column to your models.

### Prerequisites

1. The gem must be installed in a Rails application
2. You must be in the Rails application directory when running the generator

### Usage

```bash
# In your Rails application directory
rails generate playpath_rails:migration ModelName
```

### Examples

```bash
# For an Article model
rails generate playpath_rails:migration Article

# For a BlogPost model (camelCase)
rails generate playpath_rails:migration BlogPost

# For a user_profile model (snake_case)
rails generate playpath_rails:migration user_profile

# For a VideoCollection model
rails generate playpath_rails:migration VideoCollection
```

### What the Generator Creates

The generator creates a migration file that:

1. Adds a `playpath_item_id` column (integer, nullable)
2. Adds a unique index on the `playpath_item_id` column

Example generated migration:

```ruby
class AddPlaypathItemIdToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :playpath_item_id, :integer, null: true
    add_index :articles, :playpath_item_id, unique: true
  end
end
```

### After Running the Generator

1. Run the migration: `rails db:migrate`
2. Add the `Synchronizable` module to your model:

```ruby
class Article < ApplicationRecord
  include PlaypathRails::Synchronizable
  
  playpath_sync(
    title_field: :title,
    text_field: :content
  )
end
```

### Troubleshooting

**Error: "Could not find generator 'playpath_rails:migration'"**

This error occurs when:
- You're not in a Rails application directory
- The gem is not properly installed in the Rails app
- You're trying to run the generator from the gem's own directory

**Solution:** Make sure you're in a Rails application directory and the `playpath_rails` gem is added to your Gemfile.