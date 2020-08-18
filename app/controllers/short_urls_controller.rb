class ShortUrlsController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  def index
    short_urls = ShortUrl.select(:click_count, :short_code, :full_url, :title).
                          order(click_count: :desc).
                          limit(100)

    render json: { urls: short_urls.as_json(except: :id) }
  end

  def create
    short_url = ShortUrl.find_or_initialize_by(full_url: short_url_params[:full_url])
    short_url.short_code = short_url.short_code
    short_url.save!
    render json: { short_code: short_url.short_code }
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: short_url.errors.full_messages }, status: :bad_request
  end

  def show
    short_url = ShortUrl.where(short_code: short_url_params[:id]).last
    if short_url.nil?
      return render json: { message: 'Not a valid short code' }, status: :not_found
    end

    short_url.update! click_count: (short_url.click_count + 1)

    respond_to do |format|
      format.html { redirect_to short_url.full_url }
      format.json { render json: { redirect: short_url.full_url, click_count: short_url.click_count } }
    end
  end

  private

  def short_url_params
    params.permit(:id, :full_url)
  end

end
