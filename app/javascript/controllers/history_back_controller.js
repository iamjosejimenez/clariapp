import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.buttonTarget.disabled = !this.canGoBack()
  }

  goBack(event) {
    if (!this.canGoBack()) {
      event.preventDefault()
      return
    }

    window.history.back()
  }

  canGoBack() {
    return window.history.length > 1
  }
}
