class ShortUrl < ApplicationRecord

  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze

  validates :full_url, presence: true
  validate :validate_full_url

  after_create :update_title!

  def short_code
    return self[:short_code] if self[:short_code].present?
    return if self.full_url.blank?

    last_short_url = ShortUrl.last
    return CHARACTERS[0] if last_short_url.nil?

    get_next_short_code(last_short_url.short_code)
  end

  def update_title!
    ::UpdateTitleJob.perform_later(self.id)
  end

  private

  def validate_full_url
    uri = URI.parse(full_url)
    errors.add(:full_url, 'is not a valid url') unless uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    errors.add(:full_url, 'is not a valid url')
  end

  # Returns the next short code based on last ShiftUrl's short code
  def get_next_short_code(last_short_code)
    next_short_code = ""
    i = last_short_code.length - 1
    while(i >= 0) do
      character_index = CHARACTERS.find_index(last_short_code[i])
      
      if character_index < (CHARACTERS.length - 1)
        next_short_code += CHARACTERS[character_index + 1]
        i = i - 1
        break
      elsif i == 0
        next_short_code += "#{CHARACTERS[0]}#{CHARACTERS[0]}"
      else
        next_short_code += CHARACTERS[0]
      end
      i = i - 1
    end

    if i >= 0
      next_short_code += last_short_code[0..i].reverse
    end

    next_short_code.reverse
  end

end
