# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'

RSpec.describe 'Controller Integration' do
  describe 'Parameter Handling' do
    # Mock controller class to test parameter handling logic
    let(:controller_class) do
      Class.new do
        attr_accessor :params

        def initialize(params)
          @params = params
        end

        # Simulate Rails strong parameters behavior
        def permit(*args)
          MockParams.new(@params).permit(*args)
        end

        def require(key)
          MockParams.new(@params).require(key)
        end

        # The actual item_params method from our controller example
        def item_params
          if params[:item].present?
            # Nested format: { item: { title: "...", text: "..." } }
            params.require(:item).permit(:title, :url, :text, tags: [])
          else
            # Flat format: { title: "...", text: "..." }
            params.permit(:title, :url, :text, tags: [])
          end
        end
      end
    end

    # Mock implementation of Rails ActionController::Parameters
    class MockParams
      def initialize(params)
        @params = params.is_a?(Hash) ? params.with_indifferent_access : params
      end

      def permit(*keys)
        permitted = {}
        keys.each do |key|
          if key.is_a?(Hash)
            key.each do |k, v|
              permitted[k] = @params[k] if v.is_a?(Array) && @params[k].is_a?(Array)
            end
          elsif @params.key?(key)
            permitted[key] = @params[key]
          end
        end
        permitted.with_indifferent_access
      end

      def require(key)
        raise "param is missing or the value is empty: #{key}" unless @params.key?(key)

        MockParams.new(@params[key])
      end

      def present?
        @params.present?
      end

      def [](key)
        value = @params[key]
        # Return a MockParams object that responds to present? for nested values
        if value.is_a?(Hash)
          MockParams.new(value)
        else
          value
        end
      end
    end

    context 'with nested parameters' do
      let(:nested_params) do
        {
          item: {
            title: 'Building Attack Structure',
            text: 'Our new contributor former Black Ferns...',
            tags: %w[rugby coaching]
          },
          id: '2063',
          format: :json
        }
      end

      it 'extracts parameters from nested item key' do
        controller = controller_class.new(MockParams.new(nested_params))
        result = controller.item_params

        expect(result[:title]).to eq('Building Attack Structure')
        expect(result[:text]).to eq('Our new contributor former Black Ferns...')
        expect(result[:tags]).to eq(%w[rugby coaching])
      end

      it 'does not include unpermitted parameters' do
        controller = controller_class.new(MockParams.new(nested_params))
        result = controller.item_params

        expect(result).not_to have_key(:id)
        expect(result).not_to have_key(:format)
      end
    end

    context 'with flat parameters' do
      let(:flat_params) do
        {
          title: 'Building Attack Structure',
          text: 'Our new contributor former Black Ferns...',
          tags: %w[rugby coaching],
          id: '2063',
          format: :json
        }
      end

      it 'extracts parameters from top level' do
        controller = controller_class.new(MockParams.new(flat_params))
        result = controller.item_params

        expect(result[:title]).to eq('Building Attack Structure')
        expect(result[:text]).to eq('Our new contributor former Black Ferns...')
        expect(result[:tags]).to eq(%w[rugby coaching])
      end

      it 'does not include unpermitted parameters' do
        controller = controller_class.new(MockParams.new(flat_params))
        result = controller.item_params

        expect(result).not_to have_key(:id)
        expect(result).not_to have_key(:format)
      end
    end

    context 'with missing parameters' do
      let(:empty_params) { {} }

      it 'handles empty parameters gracefully' do
        controller = controller_class.new(MockParams.new(empty_params))
        result = controller.item_params

        expect(result).to be_a(Hash)
        expect(result).to be_empty
      end
    end

    context 'with partial parameters' do
      let(:partial_nested_params) do
        {
          item: {
            title: 'Just a title'
          }
        }
      end

      let(:partial_flat_params) do
        {
          title: 'Just a title'
        }
      end

      it 'handles partial nested parameters' do
        controller = controller_class.new(MockParams.new(partial_nested_params))
        result = controller.item_params

        expect(result[:title]).to eq('Just a title')
        expect(result[:text]).to be_nil
        expect(result[:tags]).to be_nil
      end

      it 'handles partial flat parameters' do
        controller = controller_class.new(MockParams.new(partial_flat_params))
        result = controller.item_params

        expect(result[:title]).to eq('Just a title')
        expect(result[:text]).to be_nil
        expect(result[:tags]).to be_nil
      end
    end
  end

  describe 'Integration Examples' do
    it 'provides working controller example' do
      expect(File.exist?('examples/items_controller_example.rb')).to be true
    end

    it 'provides integration documentation' do
      expect(File.exist?('CONTROLLER_INTEGRATION.md')).to be true
    end

    it 'controller example contains proper parameter handling' do
      content = File.read('examples/items_controller_example.rb')

      expect(content).to include('def item_params')
      expect(content).to include('if params[:item].present?')
      expect(content).to include('params.require(:item).permit')
      expect(content).to include('params.permit(:title, :url, :text, tags: [])')
    end
  end
end
