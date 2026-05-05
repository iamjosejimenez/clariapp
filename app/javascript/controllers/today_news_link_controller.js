import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    baseUrl: String
  }

  goToToday(event) {
    event.preventDefault()
    Turbo.visit(this.todayUrl())
  }

  todayUrl() {
    const now = new Date()
    const year = now.getFullYear()
    const month = String(now.getMonth() + 1).padStart(2, "0")
    const day = String(now.getDate()).padStart(2, "0")
    return `${this.baseUrlValue}?date=${year}-${month}-${day}`
  }
}
