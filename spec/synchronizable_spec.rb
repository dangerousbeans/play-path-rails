# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PlaypathRails::Synchronizable do
  let(:dummy_class) do
    Class.new do
      include PlaypathRails::Synchronizable
      
      attr_accessor :id, :title, :content, :url, :tags, :playpath_item_id
      
      def initialize(attributes = {})
        attributes.each { |key, value| send("#{key}=", value) }
      end
      
      def saved_change_to_attribute?(attr)
        true # Simulate that attributes have changed
      end
      
      def update_column(column, value)
        send("#{column}=", value)
      end
      
      def read_attribute(attr)
        send(attr)
      end
      
      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s.end_with?('=') || super
      end
      
      def method_missing(method_name, *args, &block)
        if method_name.to_s.end_with?('=')
          instance_variable_set("@#{method_name.to_s.chomp('=')}", args.first)
        else
          instance_variable_get("@#{method_name}")
        end
      end
    end
  end

  subject(:klass) { dummy_class }

  it 'provides class method playpath_sync' do
    expect(klass).to respond_to(:playpath_sync)
  end

  it 'provides class method playpath_sync_options' do
    expect(klass).to respond_to(:playpath_sync_options)
  end

  it 'provides instance method playpath_sync!' do
    expect(klass.new).to respond_to(:playpath_sync!)
  end

  it 'provides instance method playpath_delete!' do
    expect(klass.new).to respond_to(:playpath_delete!)
  end

  it 'provides instance method sync_to_playpath!' do
    expect(klass.new).to respond_to(:sync_to_playpath!)
  end

  context 'when playpath_sync is configured' do
    before do
      klass.playpath_sync(
        only: [:title, :content],
        title_field: :title,
        text_field: :content,
        tags: ['article']
      )
    end

    it 'stores options for syncing' do
      expected_options = {
        only: [:title, :content],
        title_field: :title,
        text_field: :content,
        url_field: nil,
        tags_field: nil,
        tags: ['article']
      }
      expect(klass.playpath_sync_options).to eq(expected_options)
    end
  end

  context 'with default configuration' do
    it 'has default title_field' do
      expect(klass.playpath_sync_options[:title_field]).to eq(:title)
    end
  end

  describe '#playpath_item_id' do
    let(:instance) { klass.new(playpath_item_id: 123) }

    it 'returns the playpath_item_id' do
      expect(instance.playpath_item_id).to eq(123)
    end
  end

  describe '#build_item_data' do
    let(:instance) do
      klass.new(
        title: 'Test Article',
        content: 'This is test content',
        url: 'https://example.com',
        tags: ['tag1', 'tag2']
      )
    end

    before do
      klass.playpath_sync(
        title_field: :title,
        text_field: :content,
        url_field: :url,
        tags_field: :tags,
        tags: ['static_tag']
      )
    end

    it 'builds correct item data' do
      data = instance.send(:build_item_data)
      
      expect(data[:title]).to eq('Test Article')
      expect(data[:text]).to eq('This is test content')
      expect(data[:url]).to eq('https://example.com')
      expect(data[:tags]).to include('static_tag', 'tag1', 'tag2')
    end
  end
end