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

    fields.each_with_object({}) do |(key, selector), hash|
      hash[key] = parsed_page.at_css(selector)&.text.strip
    end
  end

  def get_parsed_page(url)
    response = get_page(url)
    Nokogiri::HTML(response.body)
  end

  def get_page(url)
    HTTParty.get(url)
  end

  def handle_error(message)
    render json: { error: message }, status: :unprocessable_entity
  end
end
