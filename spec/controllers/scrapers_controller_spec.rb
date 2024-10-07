# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScrapersController, type: :controller do
  before(:each) do
    Rails.cache.clear
  end

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
      fields = { 'meta' => [ 'keywords' ] }

      allow(HTTParty).to receive(:get).and_return(double(body: '<meta name="keywords" content="test-keywords">'))

      get :show, params: { url: url, fields: fields }

      json_response = JSON.parse(response.body)
      expect(json_response['body']['meta']['keywords']).to eq('test-keywords')
    end

    it 'caches the response for repeated requests' do
      allow(HTTParty).to receive(:get).once.and_return(double(body: '<div class="price-box__price">1000</div>'))

      get :show, params: { url: url, fields: fields }
      get :show, params: { url: url, fields: fields }

      expect(HTTParty).to have_received(:get).once  # Ensure the request is only made once
      expect(response).to have_http_status(:ok)
    end
  end
end
