# frozen_string_literal: true

class ScrapersController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :handle_missing_param

  def show
    url = params[:url]
    fields = params.require(:fields).permit!.to_h

    return handle_error("You must provide url and fields params.") if url.blank? || fields.blank?

    if Rails.cache.exist?(url)
      render json: Rails.cache.read(url)
    else
      ScrapePageJob.perform_later(url, fields)
      render json: { message: "Scraping job enqueued" }, status: :accepted
    end
  end

  private

  def handle_missing_param(exception)
    handle_error("You must provide #{exception.param} param.")
  end

  def handle_error(message)
    render json: { error: message }, status: :unprocessable_entity
  end
end
