class UnsplashService
  def self.city_image(city)
    return nil if city.blank?

    response = HTTP.get("https://api.unsplash.com/search/photos", params: {
      query: "#{city} famous landmark tourism",
      per_page: 1,
      orientation: "landscape",
      content_filter: "high",
      client_id: ENV["UNSPLASH_ACCESS_KEY"]
    })

    if response.status.success?
      data = JSON.parse(response.body)
      data.dig("results", 0, "urls", "regular")
    end
  end
end
