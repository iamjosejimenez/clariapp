import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    selectedDate: String,
    url: String
  }

  connect() {
    this.lastNavigatedDate = null
    this.handleDateChange = this.handleDateChange.bind(this)
    this.inputTarget.addEventListener("changeDate", this.handleDateChange)
    this.inputTarget.addEventListener("change", this.handleDateChange)
    this.setBrowserMaxDate()
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

    const browserToday = this.browserToday()
    const safeDate = selectedDate > browserToday ? browserToday : selectedDate
    this.visitDate(safeDate)
  }

  goToToday(event) {
    event.preventDefault()
    this.visitDate(this.browserToday())
  }

  visitDate(date, options = {}) {
    const formattedDate = this.formatIsoDate(date)
    if (formattedDate === this.lastNavigatedDate) {
      return
    }

    this.lastNavigatedDate = formattedDate
    Turbo.visit(`${this.urlValue}?date=${formattedDate}`, options)
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

  browserToday() {
    const now = new Date()
    return new Date(now.getFullYear(), now.getMonth(), now.getDate())
  }

  formatIsoDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
  }

  formatPickerDate(date) {
    const day = String(date.getDate()).padStart(2, "0")
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const year = date.getFullYear()
    return `${day}/${month}/${year}`
  }

  setBrowserMaxDate() {
    this.inputTarget.setAttribute("datepicker-max-date", this.formatPickerDate(this.browserToday()))
  }
}
