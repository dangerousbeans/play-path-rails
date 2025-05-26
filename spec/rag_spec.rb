# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PlaypathRails::RAG do
  let(:mock_client) { double('client') }

  before do
    allow(PlaypathRails).to receive(:client).and_return(mock_client)
  end

  describe '.chat' do
    let(:message) { 'What is rugby?' }
    let(:history) { [{ 'role' => 'user', 'text' => 'Previous question' }] }
    let(:expected_response) { { 'reply' => 'Rugby is a sport...', 'usage' => 5, 'limit' => 20 } }

    it 'calls the client chat method with correct parameters' do
      expect(mock_client).to receive(:chat).with(message: message, history: history).and_return(expected_response)

      result = described_class.chat(message: message, history: history)
      expect(result).to eq(expected_response)
    end

    it 'works without history' do
      expect(mock_client).to receive(:chat).with(message: message, history: []).and_return(expected_response)

      result = described_class.chat(message: message)
      expect(result).to eq(expected_response)
    end
  end

  describe '.ask' do
    let(:message) { 'What is rugby?' }
    let(:response) { { 'reply' => 'Rugby is a sport...', 'usage' => 5, 'limit' => 20 } }

    it 'returns just the reply text' do
      expect(mock_client).to receive(:chat).with(message: message, history: []).and_return(response)

      result = described_class.ask(message)
      expect(result).to eq('Rugby is a sport...')
    end
  end

  describe '.build_history' do
    it 'builds alternating user/assistant history' do
      result = described_class.build_history(
        'What is rugby?',
        'Rugby is a sport...',
        'How many players?',
        'There are 15 players...'
      )

      expected = [
        { 'role' => 'user', 'text' => 'What is rugby?' },
        { 'role' => 'assistant', 'text' => 'Rugby is a sport...' },
        { 'role' => 'user', 'text' => 'How many players?' },
        { 'role' => 'assistant', 'text' => 'There are 15 players...' }
      ]

      expect(result).to eq(expected)
    end

    it 'handles single message' do
      result = described_class.build_history('What is rugby?')

      expected = [
        { 'role' => 'user', 'text' => 'What is rugby?' }
      ]

      expect(result).to eq(expected)
    end

    it 'handles empty input' do
      result = described_class.build_history
      expect(result).to eq([])
    end
  end
end
