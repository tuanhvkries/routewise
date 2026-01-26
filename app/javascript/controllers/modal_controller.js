import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  open() { this.containerTarget.classList.add("is-open") }
  close() { this.containerTarget.classList.remove("is-open") }
}
