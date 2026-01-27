import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open() {
    this.dialogTarget.classList.remove("is-hidden")
  }

  close() {
    this.dialogTarget.classList.add("is-hidden")
  }
}
