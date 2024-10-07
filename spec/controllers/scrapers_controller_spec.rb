# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScrapersController, type: :controller do
  describe 'GET #scrape' do
    let(:url) { 'https://example.com' }
    let(:fields) { { 'price': '.price-box__price' } }

    it 'scrapes fields using CSS selectors' do
      allow(HTTParty).to receive(:get).and_return(double(body: '<div class="price-box__price">1000</div>'))

      get :show, params: { url: url, fields: fields }

      json_response = JSON.parse(response.body)
      expect(json_response['body']['price']).to eq('1000')
    end

    it 'scrapes meta fields from the page' do
      url = 'https://example.com'
      fields = { 'meta' => [ 'keywords' ] }

      allow(HTTParty).to receive(:get).and_return(double(body: '<meta name="keywords" content="test-keywords">'))

      get :show, params: { url: url, fields: fields }

      json_response = JSON.parse(response.body)
      expect(json_response['body']['meta']['keywords']).to eq('test-keywords')
    end
  end
end
