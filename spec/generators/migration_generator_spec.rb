# frozen_string_literal: true

require 'spec_helper'
require 'generators/playpath_rails/migration_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe PlaypathRails::Generators::MigrationGenerator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new([model_name], {}, destination_root: destination_root) }
  let(:model_name) { 'Article' }

  before do
    # Mock ActiveRecord::Migration.current_version
    allow(ActiveRecord::Migration).to receive(:current_version).and_return(7.0)
    
    # Create the db/migrate directory
    FileUtils.mkdir_p(File.join(destination_root, 'db', 'migrate'))
  end

  after do
    # Clean up generated files
    FileUtils.rm_rf(destination_root)
  end

  describe '#create_migration_file' do
    context 'with a simple model name' do
      let(:model_name) { 'Article' }

      it 'creates a migration file with correct name pattern' do
        generator.create_migration_file
        
        migration_files = Dir[File.join(destination_root, 'db/migrate/*_add_playpath_item_id_to_articles.rb')]
        expect(migration_files).not_to be_empty
      end

      it 'generates correct migration content' do
        generator.create_migration_file
        
        migration_file = Dir[File.join(destination_root, 'db/migrate/*_add_playpath_item_id_to_articles.rb')].first
        content = File.read(migration_file)
        
        expect(content).to include('class AddPlaypathItemIdToArticles < ActiveRecord::Migration[7.0]')
        expect(content).to include('add_column :articles, :playpath_item_id, :integer, null: true')
        expect(content).to include('add_index :articles, :playpath_item_id, unique: true')
      end
    end

    context 'with a camelCase model name' do
      let(:model_name) { 'BlogPost' }

      it 'creates a migration file with correct table name' do
        generator.create_migration_file
        
        migration_files = Dir[File.join(destination_root, 'db/migrate/*_add_playpath_item_id_to_blog_posts.rb')]
        expect(migration_files).not_to be_empty
      end

      it 'generates correct migration class name and content' do
        generator.create_migration_file
        
        migration_file = Dir[File.join(destination_root, 'db/migrate/*_add_playpath_item_id_to_blog_posts.rb')].first
        content = File.read(migration_file)
        
        expect(content).to include('class AddPlaypathItemIdToBlogPosts < ActiveRecord::Migration[7.0]')
        expect(content).to include('add_column :blog_posts, :playpath_item_id, :integer, null: true')
        expect(content).to include('add_index :blog_posts, :playpath_item_id, unique: true')
      end
    end

    context 'with a snake_case model name' do
      let(:model_name) { 'user_profile' }

      it 'creates a migration file with correct table name' do
        generator.create_migration_file
        
        migration_files = Dir[File.join(destination_root, 'db/migrate/*_add_playpath_item_id_to_user_profiles.rb')]
        expect(migration_files).not_to be_empty
      end

      it 'generates correct migration class name and content' do
        generator.create_migration_file
        
        migration_file = Dir[File.join(destination_root, 'db/migrate/*_add_playpath_item_id_to_user_profiles.rb')].first
        content = File.read(migration_file)
        
        expect(content).to include('class AddPlaypathItemIdToUserProfiles < ActiveRecord::Migration[7.0]')
        expect(content).to include('add_column :user_profiles, :playpath_item_id, :integer, null: true')
        expect(content).to include('add_index :user_profiles, :playpath_item_id, unique: true')
      end
    end

    context 'with a plural model name' do
      let(:model_name) { 'Users' }

      it 'creates a migration file with correct table name' do
        generator.create_migration_file
        
        migration_files = Dir[File.join(destination_root, 'db/migrate/*_add_playpath_item_id_to_users.rb')]
        expect(migration_files).not_to be_empty
      end

      it 'generates correct migration class name and content' do
        generator.create_migration_file
        
        migration_file = Dir[File.join(destination_root, 'db/migrate/*_add_playpath_item_id_to_users.rb')].first
        content = File.read(migration_file)
        
        expect(content).to include('class AddPlaypathItemIdToUsers < ActiveRecord::Migration[7.0]')
        expect(content).to include('add_column :users, :playpath_item_id, :integer, null: true')
        expect(content).to include('add_index :users, :playpath_item_id, unique: true')
      end
    end
  end

  describe 'private methods' do
    describe '#table_name' do
      it 'returns the tableized model name' do
        generator = described_class.new(['Article'])
        expect(generator.send(:table_name)).to eq('articles')
      end

      context 'with camelCase model' do
        it 'returns the correct table name' do
          generator = described_class.new(['BlogPost'])
          expect(generator.send(:table_name)).to eq('blog_posts')
        end
      end

      context 'with snake_case model' do
        it 'returns the correct table name' do
          generator = described_class.new(['user_profile'])
          expect(generator.send(:table_name)).to eq('user_profiles')
        end
      end
    end

    describe '#migration_class_name' do
      it 'returns the correct migration class name' do
        generator = described_class.new(['Article'])
        expect(generator.send(:migration_class_name)).to eq('AddPlaypathItemIdToArticles')
      end

      context 'with camelCase model' do
        it 'returns the correct migration class name' do
          generator = described_class.new(['BlogPost'])
          expect(generator.send(:migration_class_name)).to eq('AddPlaypathItemIdToBlogPosts')
        end
      end

      context 'with snake_case model' do
        it 'returns the correct migration class name' do
          generator = described_class.new(['user_profile'])
          expect(generator.send(:migration_class_name)).to eq('AddPlaypathItemIdToUserProfiles')
        end
      end

      context 'with plural model' do
        it 'returns the correct migration class name' do
          generator = described_class.new(['Users'])
          expect(generator.send(:migration_class_name)).to eq('AddPlaypathItemIdToUsers')
        end
      end
    end
  end

  describe 'argument validation' do
    it 'requires a model name argument' do
      expect { described_class.new([]) }.to raise_error(Thor::RequiredArgumentMissingError)
    end

    it 'accepts a model name argument' do
      expect { described_class.new(['Article']) }.not_to raise_error
    end
  end
end