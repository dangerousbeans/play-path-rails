# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PlaypathRails::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it 'has nil api_key' do
      expect(config.api_key).to be_nil
    end

    it 'has nil embeddings_api_key' do
      expect(config.embeddings_api_key).to be_nil
    end

    it 'has default base_url' do
      expect(config.base_url).to eq('https://playpath.io')
    end
  end

  describe 'assignment' do
    it 'allows setting api_key' do
      config.api_key = 'secret_key'
      expect(config.api_key).to eq('secret_key')
    end

    it 'allows setting embeddings_api_key' do
      config.embeddings_api_key = 'embeddings_key'
      expect(config.embeddings_api_key).to eq('embeddings_key')
    end

    it 'allows setting base_url' do
      config.base_url = 'https://custom-url'
      expect(config.base_url).to eq('https://custom-url')
    end
  end

  describe '#api_key_for' do
    before do
      config.api_key = 'regular_key'
      config.embeddings_api_key = 'embeddings_key'
    end

    it 'returns regular api_key for items endpoint' do
      expect(config.api_key_for(:items)).to eq('regular_key')
    end

    it 'returns embeddings_api_key for rag endpoint when available' do
      expect(config.api_key_for(:rag)).to eq('embeddings_key')
    end

    it 'falls back to regular api_key for rag endpoint when embeddings_api_key is nil' do
      config.embeddings_api_key = nil
      expect(config.api_key_for(:rag)).to eq('regular_key')
    end

    it 'returns regular api_key for unknown endpoint types' do
      expect(config.api_key_for(:unknown)).to eq('regular_key')
    end
  end
end

RSpec.describe PlaypathRails do
  after do
    # reset configuration between tests
    PlaypathRails.configuration = nil
  end

  describe '.configure' do
    before do
      PlaypathRails.configure do |c|
        c.api_key = 'test_api_key'
        c.embeddings_api_key = 'test_embeddings_key'
        c.base_url = 'https://custom-api'
      end
    end

    it 'yields the configuration object' do
      expect(PlaypathRails.configuration).to be_an_instance_of(PlaypathRails::Configuration)
    end

    it 'sets the api_key' do
      expect(PlaypathRails.configuration.api_key).to eq('test_api_key')
    end

    it 'sets the embeddings_api_key' do
      expect(PlaypathRails.configuration.embeddings_api_key).to eq('test_embeddings_key')
    end

    it 'sets the base_url' do
      expect(PlaypathRails.configuration.base_url).to eq('https://custom-api')
    end
  end

  describe '.configuration' do
    it 'memoizes the configuration object' do
      PlaypathRails.configure {}
      first = PlaypathRails.configuration
      PlaypathRails.configure {}
      expect(PlaypathRails.configuration).to equal(first)
    end
  end

  describe '.client' do
    before do
      PlaypathRails.configure do |c|
        c.api_key = 'test_api_key'
      end
    end

    it 'returns a client instance' do
      expect(PlaypathRails.client).to be_an_instance_of(PlaypathRails::Client)
    end

    it 'memoizes the client instance' do
      first = PlaypathRails.client
      second = PlaypathRails.client
      expect(first).to equal(second)
    end
  end
end