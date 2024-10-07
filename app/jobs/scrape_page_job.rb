# frozen_string_literal: true

require "nokogiri"
require "httparty"

class ScrapePageJob < ApplicationJob
  queue_as :default

  def perform(url, fields)
    scraped_url = scrape(url, fields)
    Rails.cache.write(url, scraped_url, expires_in: 12.hours)
  end

  private

  def scrape(url, fields)
    parsed_page = get_parsed_page(url)

    fields.each_with_object({}) do |(key, value), hash|
      if key == "meta"
        hash[key] = fetch_meta(parsed_page, value)
      else
        element = parsed_page.is_a?(Hash) ? nil : parsed_page.at_css(value)
        hash[key] = element ? element.text.strip : nil
      end
    end
  end

  def fetch_meta(parsed_page, meta_fields)
    if parsed_page.is_a?(Hash)
      return parsed_page["meta"]
    end

    meta_fields.each_with_object({}) do |meta_name, meta_hash|
      meta_hash[meta_name] = parsed_page.at_xpath("//meta[@name='#{meta_name}']/@content")&.value
    end
  end

  def get_parsed_page(url)
    cached_data = Rails.cache.read(url)
    return cached_data if cached_data.is_a?(Hash)

    response = get_page(url)
    response.nil? ? nil : Nokogiri::HTML(response.body)
  end

  def get_page(url)
    HTTParty.get(url)
  rescue StandardError => e
    Rails.logger.error("Failed to fetch page at #{url}: #{e.message}")
    nil
  end
end
