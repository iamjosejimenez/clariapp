import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "image", "placeholder"]

  connect() {
    this.objectUrl = null
  }

  disconnect() {
    this._revokeObjectUrl()
  }

  update() {
    const file = this.inputTarget?.files?.[0]

    if (!file) {
      this.clear()
      return
    }

    this._revokeObjectUrl()
    this.objectUrl = URL.createObjectURL(file)

    this.imageTarget.src = this.objectUrl
    this.imageTarget.alt = file.name
    this.imageTarget.classList.remove("hidden")

    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.add("hidden")
    }
  }

  clear() {
    this._revokeObjectUrl()

    this.imageTarget.removeAttribute("src")
    this.imageTarget.classList.add("hidden")

    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.remove("hidden")
    }
  }

  _revokeObjectUrl() {
    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl)
      this.objectUrl = null
    }
  }
}
