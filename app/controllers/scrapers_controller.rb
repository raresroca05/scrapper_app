# frozen_string_literal: true

require "nokogiri"
require "httparty"

class ScrapersController < ApplicationController
  def show
    url = params[:url]
    fields = params.require(:fields).permit!.to_h

    return handle_error("You must provide url and fields params.") if url.blank? || fields.blank?

    render json: { body: scrape(url, fields) }, status: :ok
  end

  private

  def scrape(url, fields)
    parsed_page = get_parsed_page(url)

    fields.each_with_object({}) do |(key, value), hash|
      if key == "meta"
        hash[key] = fetch_meta(parsed_page, value)
      else
        hash[key] = parsed_page.at_css(value)&.text.strip
      end
    end
  end

  def fetch_meta(parsed_page, meta_fields)
    meta_fields.each_with_object({}) do |meta_name, meta_hash|
      meta_hash[meta_name] = parsed_page.at_xpath("//meta[@name='#{meta_name}']/@content")&.value
    end
  end

  def get_parsed_page(url)
    response_body = get_cached_page(url)
    Nokogiri::HTML(response_body)
  end

  def get_cached_page(url)
    Rails.cache.fetch(url, expires_in: 12.hours) do
      HTTParty.get(url).body
    end
  end

  def handle_error(message)
    render json: { error: message }, status: :unprocessable_entity
  end
end
