# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScrapersController, type: :controller do
  let(:url) { 'https://example.com' }
  let(:fields) { { 'price' => '.price-box__price' } }

  before do
    Rails.cache.clear
  end

  describe 'GET #show' do
    context 'when parameters are missing' do
      it 'returns an error when url is missing' do
        get :show, params: { fields: fields }

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('You must provide url and fields params.')
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an error when fields are missing' do
        get :show, params: { url: url }

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('You must provide fields param.')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when data is cached' do
      it 'returns the cached data' do
        Rails.cache.write(url, { "price" => "1000" }, expires_in: 12.hours)

        get :show, params: { url: url, fields: fields }

        json_response = JSON.parse(response.body)
        expect(json_response['price']).to eq('1000')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when data is not cached' do
      it 'enqueues the ScrapePageJob and returns accepted status' do
        allow(ScrapePageJob).to receive(:perform_later)

        get :show, params: { url: url, fields: fields }

        expect(ScrapePageJob).to have_received(:perform_later).with(url, fields)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Scraping job enqueued')
        expect(response).to have_http_status(:accepted)
      end
    end
  end
end
