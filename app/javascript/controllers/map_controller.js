import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    token: String,
    markers: Array
  }

  connect() {
    mapboxgl.accessToken = this.tokenValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12",
      center: [0, 0],
      zoom: 12
    })

    this.map.addControl(new mapboxgl.NavigationControl())

    const bounds = new mapboxgl.LngLatBounds()
    let hasValidMarker = false

    this.markersValue.forEach(marker => {
      if (marker.lat == null || marker.lng == null) return

      hasValidMarker = true
      const mapsUrl = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(marker.title + " " + (marker.location || ""))}`
      const popup = new mapboxgl.Popup({ offset: 25 }).setHTML(
        `<strong>${marker.title}</strong><br><span style="font-size:12px;color:#666">${marker.location || ""}</span><br><a href="${mapsUrl}" target="_blank" rel="noopener" style="font-size:12px">View on Google Maps</a>`
      )

      new mapboxgl.Marker({ color: "#234B52" })
        .setLngLat([marker.lng, marker.lat])
        .setPopup(popup)
        .addTo(this.map)

      bounds.extend([marker.lng, marker.lat])
    })

    if (hasValidMarker) {
      this.map.fitBounds(bounds, { padding: 50, maxZoom: 14 })
    }
  }

  disconnect() {
    if (this.map) this.map.remove()
  }
}
