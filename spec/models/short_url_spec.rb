require 'rails_helper'

RSpec.describe ShortUrl, type: :model do

  describe "ShortUrl" do

    let(:short_url) { ShortUrl.create(full_url: "https://www.beenverified.com/faq/", short_code: "faq") }

    it "finds a short_url with the short_code" do
      expect(ShortUrl.find_by_short_code(short_url.short_code)).to eq short_url
    end

  end

  describe "a new short_url instance" do

    let(:short_url) { ShortUrl.new }

    it "isn't valid without a full_url" do
      expect(short_url).to_not be_valid
      expect(short_url.errors[:full_url]).to be_include("can't be blank")
    end

    it "has an invalid url" do
      short_url.full_url = 'javascript:alert("Hello World");'
      expect(short_url).to_not be_valid
      expect(short_url.errors[:full_url]).to be_include("is not a valid url")
    end

    it "doesn't have a short_code" do
      expect(short_url.short_code).to be_nil
    end

    it "returns the next short_code" do
      short_url.full_url = "https://www.google.com"

      last_short_url = ShortUrl.create(full_url: "https://www.beenverified.com/faq/", short_code: "0")
      expect(short_url.short_code).to eq "1"

      last_short_url.update short_code: "Z"
      expect(short_url.short_code).to eq "00"

      last_short_url.update short_code: "1Z"
      expect(short_url.short_code).to eq "20"
    end

  end

  describe "existing short_url instance" do

    let(:short_url) { ShortUrl.create(full_url: "https://www.beenverified.com/faq/", short_code: "0") }

    it "has a short code" do
      # Just validate the short_code class bc specs run in random order
      # and we don't actually know what the string is going to be
      expect(short_url.short_code).to be_a(String)
    end

    it "has a click_counter" do
      expect(short_url.click_count).to eq 0
    end

    it "fetches the title" do
      short_url.update_title!
      expect(short_url.reload.title).to eq("Frequently Asked Questions | BeenVerified")
    end

    context "with a higher id" do

      before do
        short_url
      end

      it "should return the existing short code if exists" do
        short_url.update_column(:id, 1001)
        expect(short_url.short_code).to eq("0")
      end

      it "should return the next short code" do
        new_short_url = ShortUrl.new(full_url: "https://wwww.google.com")
        expect(new_short_url.short_code).to eq("1")
      end
    end

  end

end
