import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["picker", "startDate", "endDate"]

  connect() {
    const startValue = this.startDateTarget.value
    const endValue = this.endDateTarget.value
    const defaultDates = startValue && endValue ? [startValue, endValue] : []

    this.fp = flatpickr(this.pickerTarget, {
      mode: "range",
      minDate: "today",
      dateFormat: "Y-m-d",
      altInput: true,
      altFormat: "j M Y",
      altInputClass: "rw-input flatpickr-input",
      defaultDate: defaultDates,
      onChange: (selectedDates) => {
        if (selectedDates.length === 2) {
          this.startDateTarget.value = this.formatDate(selectedDates[0])
          this.endDateTarget.value = this.formatDate(selectedDates[1])
        }
      }
    })
  }

  formatDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  disconnect() {
    if (this.fp) {
      this.fp.destroy()
    }
  }
}
