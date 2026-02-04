class UnsplashService
  STYLES = {
    landmark: "famous landmark tourism",
    skyline: "city skyline panorama"
  }.freeze

  def self.city_image(city, style: :landmark)
    return nil if city.blank?

    query_suffix = STYLES[style] || STYLES[:landmark]

    params = {
      query: "#{city} #{query_suffix}",
      per_page: 1,
      orientation: "landscape",
      content_filter: "high",
      client_id: ENV["UNSPLASH_ACCESS_KEY"]
    }

    conn = Faraday.new(url: "https://api.unsplash.com") do |f|
      f.request :url_encoded
      f.response :json
    end

    response = conn.get("/search/photos", params)

    if response.success?
      response.body.dig("results", 0, "urls", "regular")
    end
  rescue StandardError => e
    Rails.logger.error("UnsplashService error: #{e.message}")
    nil
  end
end
