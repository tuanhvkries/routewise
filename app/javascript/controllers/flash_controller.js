import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: Number }

  connect() {
    const ms = this.timeoutValue || 3500
    this.timer = setTimeout(() => this.hide(), ms)
  }

  disconnect() {
    if (this.timer) clearTimeout(this.timer)
  }

  hide() {
    // hide the inner flash boxes smoothly, then remove wrapper
    this.element.querySelectorAll(".rw-flash").forEach((el) => el.classList.add("is-hiding"))

    setTimeout(() => {
      this.element.remove()
    }, 260)
  }
}
