import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import { Datepicker } from "flowbite"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    maxDate: String,
    url: String
  }

  connect() {
    this.lastNavigatedDate = null
    this.datepicker = new Datepicker(this.inputTarget, {
      autohide: true,
      format: "dd/mm/yyyy",
      maxDate: this.parseIsoDate(this.maxDateValue)
    })

    this.handleDateChange = this.handleDateChange.bind(this)
    this.inputTarget.addEventListener("changeDate", this.handleDateChange)
    this.inputTarget.addEventListener("change", this.handleDateChange)
  }

  disconnect() {
    this.inputTarget.removeEventListener("changeDate", this.handleDateChange)
    this.inputTarget.removeEventListener("change", this.handleDateChange)

    if (this.datepicker) {
      this.datepicker.destroy()
      this.datepicker = null
    }
  }

  handleDateChange(event) {
    const selectedDate = event?.detail?.date || this.parseDateFromInput()
    if (!(selectedDate instanceof Date) || Number.isNaN(selectedDate.getTime())) {
      return
    }

    const formattedDate = this.formatIsoDate(selectedDate)
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

  formatIsoDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
  }
}
