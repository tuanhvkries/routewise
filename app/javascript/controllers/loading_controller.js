import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.overlay = null
    this.timer = null
    this.index = 0

    this.messages = [
      "Analyzing your preferences…",
      "Checking transport options…",
      "Saving CO2…",
      "Adding activities…",
      "Arranging activities…",
      "Optimizing your schedule…",
      "Finalizing your trip…"
    ]
  }

  start() {
    this.showOverlay()
  }

  stop() {
    this.hideOverlay()
  }

  showOverlay() {
    if (this.overlay) return

    this.overlay = document.createElement("div")
    this.overlay.className = "rw-loading-overlay"
    this.overlay.innerHTML = `
      <div class="rw-loading-popup">
        <div class="rw-loading-spinner"></div>
        <p class="rw-loading-message"></p>
      </div>
    `

    document.body.appendChild(this.overlay)

    this.index = 0
    this.updateMessage()
    this.timer = setInterval(() => {
      this.index = (this.index + 1) % this.messages.length
      this.updateMessage()
    }, 3200)
  }

  updateMessage() {
    const el = this.overlay?.querySelector(".rw-loading-message")
    if (el) el.textContent = this.messages[this.index]
  }

  hideOverlay() {
    if (!this.overlay) return

    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }

    this.overlay.remove()
    this.overlay = null
  }
}
