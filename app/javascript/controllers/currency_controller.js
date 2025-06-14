import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Currency controller connected")
    const input = this.element
    const formatter = new Intl.NumberFormat("es-CL", {
      style: "currency",
      currency: "CLP",
      minimumFractionDigits: 0
    })

    const parse = (value) =>
      parseInt(value.replace(/[$\.\s]/g, '')) || 0

    input.addEventListener("input", (e) => {
      const raw = parse(e.target.value)
      e.target.value = formatter.format(raw)
    })

    input.form.addEventListener("submit", () => {
      input.value = parse(input.value)
    })
  }
}
