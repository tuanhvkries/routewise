import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slider"
export default class extends Controller {
  static targets = ["input", "track", "thumb", "value", "min", "max", "fill"]
  static values = {
    min: Number,
    max: Number,
    step: Number,
    value: Number,
    showValue: Boolean,
    showMinMax: Boolean,
    vertical: Boolean
  }

  connect() {
    this.setupSlider()
    this.updateDisplay()
  }

  setupSlider() {
    // Set initial values
    if (this.hasInputTarget) {
      this.inputTarget.min = this.minValue || 0
      this.inputTarget.max = this.maxValue || 100
      this.inputTarget.step = this.stepValue || 1
      this.inputTarget.value = this.valueValue || this.minValue || 0
    }

    // Update min/max displays
    if (this.showMinMaxValue) {
      if (this.hasMinTarget) {
        this.minTarget.textContent = this.minValue || 0
      }
      if (this.hasMaxTarget) {
        this.maxTarget.textContent = this.maxValue || 100
      }
    }
  }

  updateValue(event) {
    const value = parseFloat(event.target.value)
    this.updateDisplay(value)
    this.dispatchChangeEvent(value)
  }

  updateDisplay(value = null) {
    const currentValue = value !== null ? value : parseFloat(this.inputTarget.value)
    const min = this.minValue || 0
    const max = this.maxValue || 100
    const percentage = ((currentValue - min) / (max - min)) * 100

    // Update value display
    if (this.showValueValue && this.hasValueTarget) {
      this.valueTarget.textContent = this.formatValue(currentValue)
    }

    // Update fill/progress bar
    if (this.hasFillTarget) {
      if (this.verticalValue) {
        this.fillTarget.style.height = `${percentage}%`
      } else {
        this.fillTarget.style.width = `${percentage}%`
      }
    }

    // Update thumb position for custom sliders
    if (this.hasThumbTarget) {
      if (this.verticalValue) {
        this.thumbTarget.style.bottom = `${percentage}%`
      } else {
        this.thumbTarget.style.left = `${percentage}%`
      }
    }

    // Update data attribute for CSS styling
    this.element.dataset.value = currentValue
    this.element.dataset.percentage = Math.round(percentage)
  }

  formatValue(value) {
    // Format the value for display (can be customized)
    if (this.stepValue && this.stepValue < 1) {
      return value.toFixed(1)
    }
    return Math.round(value).toLocaleString()
  }

  setValue(value) {
    const clampedValue = Math.max(this.minValue || 0, Math.min(this.maxValue || 100, value))
    this.inputTarget.value = clampedValue
    this.updateDisplay(clampedValue)
    this.dispatchChangeEvent(clampedValue)
  }

  getValue() {
    return parseFloat(this.inputTarget.value)
  }

  increment() {
    const step = this.stepValue || 1
    const newValue = this.getValue() + step
    this.setValue(newValue)
  }

  decrement() {
    const step = this.stepValue || 1
    const newValue = this.getValue() - step
    this.setValue(newValue)
  }

  // Handle keyboard events for custom sliders
  handleKeydown(event) {
    const step = this.stepValue || 1
    const currentValue = this.getValue()

    switch (event.key) {
      case 'ArrowRight':
      case 'ArrowUp':
        event.preventDefault()
        this.setValue(currentValue + step)
        break
      case 'ArrowLeft':
      case 'ArrowDown':
        event.preventDefault()
        this.setValue(currentValue - step)
        break
      case 'Home':
        event.preventDefault()
        this.setValue(this.minValue || 0)
        break
      case 'End':
        event.preventDefault()
        this.setValue(this.maxValue || 100)
        break
      case 'PageUp':
        event.preventDefault()
        this.setValue(currentValue + (step * 10))
        break
      case 'PageDown':
        event.preventDefault()
        this.setValue(currentValue - (step * 10))
        break
    }
  }

  // Handle mouse/touch events for custom sliders
  handlePointerDown(event) {
    event.preventDefault()
    this.isDragging = true
    this.updateValueFromPointer(event)

    document.addEventListener('pointermove', this.boundHandlePointerMove)
    document.addEventListener('pointerup', this.boundHandlePointerUp)
  }

  handlePointerMove(event) {
    if (!this.isDragging) return
    this.updateValueFromPointer(event)
  }

  handlePointerUp(event) {
    this.isDragging = false
    document.removeEventListener('pointermove', this.boundHandlePointerMove)
    document.removeEventListener('pointerup', this.boundHandlePointerUp)
  }

  updateValueFromPointer(event) {
    if (!this.hasTrackTarget) return

    const rect = this.trackTarget.getBoundingClientRect()
    const min = this.minValue || 0
    const max = this.maxValue || 100

    let percentage
    if (this.verticalValue) {
      percentage = 1 - ((event.clientY - rect.top) / rect.height)
    } else {
      percentage = (event.clientX - rect.left) / rect.width
    }

    percentage = Math.max(0, Math.min(1, percentage))
    const value = min + (percentage * (max - min))

    // Snap to step
    const step = this.stepValue || 1
    const snappedValue = Math.round(value / step) * step

    this.setValue(snappedValue)
  }

  dispatchChangeEvent(value) {
    const event = new CustomEvent('slider:change', {
      detail: {
        value: value,
        percentage: ((value - (this.minValue || 0)) / ((this.maxValue || 100) - (this.minValue || 0))) * 100,
        input: this.inputTarget
      }
    })
    this.element.dispatchEvent(event)
  }

  // Bind pointer events
  initialize() {
    this.boundHandlePointerMove = this.handlePointerMove.bind(this)
    this.boundHandlePointerUp = this.handlePointerUp.bind(this)
  }
}
