import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    maxDate: String,
    selectedDate: String,
    url: String
  }

  connect() {
    this.lastNavigatedDate = null
    this.handleDateChange = this.handleDateChange.bind(this)
    this.inputTarget.addEventListener("changeDate", this.handleDateChange)
    this.inputTarget.addEventListener("change", this.handleDateChange)
    this.navigateToBrowserToday()
  }

  disconnect() {
    this.inputTarget.removeEventListener("changeDate", this.handleDateChange)
    this.inputTarget.removeEventListener("change", this.handleDateChange)
  }

  handleDateChange(event) {
    const selectedDate = event?.detail?.date || this.parseDateFromInput()
    if (!(selectedDate instanceof Date) || Number.isNaN(selectedDate.getTime())) {
      return
    }

    const maxDate = this.effectiveMaxDate()
    const safeDate = maxDate && selectedDate > maxDate ? maxDate : selectedDate

    const formattedDate = this.formatIsoDate(safeDate)
    if (formattedDate === this.lastNavigatedDate) {
      return
    }

    this.lastNavigatedDate = formattedDate
    Turbo.visit(`${this.urlValue}?date=${formattedDate}`)
  }

  parseDateFromInput() {
    const value = this.inputTarget.value
    if (!value) {
      return null
    }

    const [day, month, year] = value.split("/")
    if (!day || !month || !year) {
      return null
    }

    return new Date(Number(year), Number(month) - 1, Number(day))
  }

  parseIsoDate(value) {
    if (!value) {
      return null
    }

    const [year, month, day] = value.split("-")
    if (!year || !month || !day) {
      return null
    }

    return new Date(Number(year), Number(month) - 1, Number(day))
  }

  effectiveMaxDate() {
    const serverMaxDate = this.parseIsoDate(this.maxDateValue)
    const browserToday = this.browserToday()

    if (!serverMaxDate) {
      return browserToday
    }

    if (!browserToday) {
      return serverMaxDate
    }

    return serverMaxDate < browserToday ? serverMaxDate : browserToday
  }

  browserToday() {
    const now = new Date()
    return new Date(now.getFullYear(), now.getMonth(), now.getDate())
  }

  navigateToBrowserToday() {
    const url = new URL(window.location.href)
    if (url.searchParams.has("date")) {
      return
    }

    const browserToday = this.effectiveMaxDate()
    const selectedDate = this.parseIsoDate(this.selectedDateValue)
    if (!browserToday || !selectedDate) {
      return
    }

    const browserTodayIso = this.formatIsoDate(browserToday)
    const selectedDateIso = this.formatIsoDate(selectedDate)
    if (browserTodayIso === selectedDateIso) {
      return
    }

    this.lastNavigatedDate = browserTodayIso
    Turbo.visit(`${this.urlValue}?date=${browserTodayIso}`, { action: "replace" })
  }

  formatIsoDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
  }
}
