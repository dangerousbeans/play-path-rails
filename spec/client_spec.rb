# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PlaypathRails::Client do
  let(:configuration) do
    PlaypathRails::Configuration.new.tap do |config|
      config.api_key = 'test_api_key'
      config.base_url = 'https://test.playpath.io'
    end
  end

  subject(:client) { described_class.new(configuration) }

  describe '#initialize' do
    it 'stores the configuration' do
      expect(client.configuration).to eq(configuration)
    end
  end

  describe 'Items API methods' do
    describe '#list_items' do
      it 'responds to list_items' do
        expect(client).to respond_to(:list_items)
      end
    end

    describe '#get_item' do
      it 'responds to get_item' do
        expect(client).to respond_to(:get_item)
      end
    end

    describe '#create_item' do
      it 'responds to create_item' do
        expect(client).to respond_to(:create_item)
      end
    end

    describe '#update_item' do
      it 'responds to update_item' do
        expect(client).to respond_to(:update_item)
      end
    end

    describe '#delete_item' do
      it 'responds to delete_item' do
        expect(client).to respond_to(:delete_item)
      end
    end
  end

  describe 'RAG Chat API methods' do
    describe '#chat' do
      it 'responds to chat' do
        expect(client).to respond_to(:chat)
      end
    end
  end

  describe '#build_request' do
    it 'raises error for unsupported HTTP method' do
      expect do
        client.send(:build_request, :invalid, URI('https://test.com'), nil, :items)
      end.to raise_error(ArgumentError, 'Unsupported HTTP method: invalid')
    end
  end

  describe 'authentication' do
    context 'when no API key is configured' do
      let(:configuration) do
        PlaypathRails::Configuration.new.tap do |config|
          config.api_key = nil
          config.embeddings_api_key = nil
        end
      end

      it 'raises AuthenticationError' do
        expect do
          client.send(:build_request, :get, URI('https://test.com'), nil, :items)
        end.to raise_error(PlaypathRails::AuthenticationError, 'API key not configured')
      end
    end

    context 'with embeddings API key for RAG endpoint' do
      let(:configuration) do
        PlaypathRails::Configuration.new.tap do |config|
          config.api_key = nil
          config.embeddings_api_key = 'embeddings_key'
        end
      end

      it 'uses embeddings key for RAG endpoints' do
        request = client.send(:build_request, :post, URI('https://test.com'), nil, :rag)
        expect(request['X-Api-Key']).to eq('embeddings_key')
      end
    end
  end
end
