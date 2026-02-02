class UnsplashService
  def self.city_image(city)
    return nil if city.blank?

    params = {
      query: "#{city} famous landmark tourism",
      per_page: 1,
      orientation: "landscape",
      content_filter: "high",
      client_id: ENV["UNSPLASH_ACCESS_KEY"]
    }

    uri = URI("https://api.unsplash.com/search/photos")
    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      data.dig("results", 0, "urls", "regular")
    end
  rescue StandardError => e
    Rails.logger.error("UnsplashService error: #{e.message}")
    nil
  end
end
