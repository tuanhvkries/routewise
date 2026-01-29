import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { message: { type: String, default: "Generating your trip..." } }

  submit() {
    this.showOverlay()
  }

  showOverlay() {
    const overlay = document.createElement("div")
    overlay.className = "rw-loading-overlay"
    overlay.innerHTML = `
      <div class="rw-loading-popup">
        <div class="rw-loading-spinner"></div>
        <p class="rw-loading-message">${this.messageValue}</p>
      </div>
    `
    document.body.appendChild(overlay)
  }
}
