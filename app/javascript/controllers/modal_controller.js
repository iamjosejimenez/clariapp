import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "content", "loader"]
  static values = { url: String }

  async open(event) {
    const button = event.currentTarget
    const url = button.dataset.url

    // Mostrar modal y loader
    this.containerTarget.classList.remove("hidden")
    this.loaderTarget.classList.remove("hidden")
    this.contentTarget.classList.add("hidden")
    document.body.classList.add("overflow-hidden")

    try {
      // Hacer fetch asíncrono
      const response = await fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const html = await response.text()
        // Ejecutar el turbo stream
        Turbo.renderStreamMessage(html)

        // Ocultar loader y mostrar contenido
        this.loaderTarget.classList.add("hidden")
        this.contentTarget.classList.remove("hidden")
      }
    } catch (error) {
      console.error("Error loading snapshot detail:", error)
      this.close()
    }
  }

  close() {
    this.containerTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.containerTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
