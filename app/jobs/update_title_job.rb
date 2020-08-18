require 'open-uri'

class UpdateTitleJob < ApplicationJob
  queue_as :default

  def perform(short_url_id)
    short_url = ShortUrl.find(short_url_id)
    return if short_url.title.present?

    title = Nokogiri::HTML.parse(open(short_url.full_url)).title
    short_url.update title: title
  end
end
