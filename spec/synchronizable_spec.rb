# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PlaypathRails::Synchronizable do
  let(:dummy_class) do
    Class.new do
      include PlaypathRails::Synchronizable
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

  context 'when playpath_sync is configured' do
    before do
      klass.playpath_sync(only: [:title, :content], index: 'articles_index')
    end

    it 'stores options for syncing' do
      expect(klass.playpath_sync_options).to eq(only: [:title, :content], index: 'articles_index')
    end
  end
end