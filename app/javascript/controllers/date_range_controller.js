import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["start", "end", "error"]

  connect() {
    this.updateEndMin()
  }

  updateEndMin() {
    this.clearError()
    if (this.startTarget.value) {
      this.endTarget.min = this.startTarget.value
      if (this.endTarget.value && this.endTarget.value < this.startTarget.value) {
        this.showError("End date must be on or after start date")
        this.endTarget.value = this.startTarget.value
      }
    }
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.add("is-visible")
    }
  }

  clearError() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = ""
      this.errorTarget.classList.remove("is-visible")
    }
  }
}
