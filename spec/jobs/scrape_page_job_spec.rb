# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScrapePageJob, type: :job do
  let(:url) { 'https://example.com' }
  let(:fields) { { 'price' => '.price-box__price', 'meta' => [ 'keywords' ] } }

  before do
    Rails.cache.clear
  end

  context 'when scraping page elements' do
    it 'scrapes the page and writes to cache' do
      allow(HTTParty).to receive(:get).and_return(double(body: '<div class="price-box__price">1000</div><meta name="keywords" content="test-keywords">'))

      described_class.perform_now(url, fields)

      cached_response = Rails.cache.read(url)

      expect(cached_response).to eq({
        "price" => "1000",
        "meta" => { "keywords" => "test-keywords" }
      })

      expect(HTTParty).to have_received(:get).once
    end

    it 'returns nil for missing elements' do
      allow(HTTParty).to receive(:get).and_return(double(body: '<meta name="keywords" content="test-keywords">'))

      described_class.perform_now(url, fields)

      cached_response = Rails.cache.read(url)
      expect(cached_response).to eq({
        "price" => nil,
        "meta" => { "keywords" => "test-keywords" }
      })
    end

    it 'handles missing meta tags' do
      allow(HTTParty).to receive(:get).and_return(double(body: '<div class="price-box__price">1000</div>'))

      described_class.perform_now(url, fields)

      cached_response = Rails.cache.read(url)
      expect(cached_response).to eq({
        "price" => "1000",
        "meta" => { "keywords" => nil }
      })
    end
  end

  context 'when using cache' do
    it 'uses the cache and does not make an HTTP request again' do
      Rails.cache.write(url, { "price" => nil, "meta" => { "keywords" => "cached-keywords" } }, expires_in: 12.hours)

      allow(HTTParty).to receive(:get)

      described_class.perform_now(url, fields)

      expect(HTTParty).not_to have_received(:get)

      cached_response = Rails.cache.read(url)
      expect(cached_response).to eq({
        "price" => nil,
        "meta" => { "keywords" => "cached-keywords" }
      })
    end
  end
end
