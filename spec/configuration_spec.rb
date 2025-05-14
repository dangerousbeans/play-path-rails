# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PlaypathRails::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it 'has nil api_key' do
      expect(config.api_key).to be_nil
    end

    it 'has default base_url' do
      expect(config.base_url).to eq('https://api.playpath.io')
    end
  end

  describe 'assignment' do
    it 'allows setting api_key' do
      config.api_key = 'secret_key'
      expect(config.api_key).to eq('secret_key')
    end

    it 'allows setting base_url' do
      config.base_url = 'https://custom-url'
      expect(config.base_url).to eq('https://custom-url')
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
        c.base_url = 'https://custom-api'
      end
    end

    it 'yields the configuration object' do
      expect(PlaypathRails.configuration).to be_an_instance_of(PlaypathRails::Configuration)
    end

    it 'sets the api_key' do
      expect(PlaypathRails.configuration.api_key).to eq('test_api_key')
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
end