import { Controller } from "@hotwired/stimulus"
import { Modal } from "flowbite"

export default class extends Controller {
  static targets = ["content", "loader"]

  connect() {
    const modalElement = this.modalElement()
    if (!modalElement) return

    this.modalInstance = new Modal(modalElement, {
      closable: false
    })
  }

  async open(event) {
    const url = event.currentTarget.dataset.url
    if (!url || !this.modalInstance) return

    this.lastTrigger = event.currentTarget
    this.modalInstance.show()
    this.loaderTarget.classList.remove("hidden")
    this.contentTarget.classList.add("hidden")

    try {
      const response = await fetch(url, {
        headers: {
          Accept: "text/vnd.turbo-stream.html"
        }
      })

      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const html = await response.text()
      Turbo.renderStreamMessage(html)
      this.loaderTarget.classList.add("hidden")
      this.contentTarget.classList.remove("hidden")
    } catch (error) {
      console.error("Error loading snapshot detail:", error)
      this.loaderTarget.classList.add("hidden")
    }
  }

  close() {
    if (!this.modalInstance) return

    const modalElement = this.modalElement()
    const activeElement = document.activeElement

    if (modalElement && activeElement && modalElement.contains(activeElement) && typeof activeElement.blur === "function") {
      activeElement.blur()
    }

    this.modalInstance.hide()

    if (this.lastTrigger && typeof this.lastTrigger.focus === "function") {
      this.lastTrigger.focus()
    }
  }

  closeOnBackdrop(event) {
    const modalElement = this.modalElement()
    if (modalElement && event.target === modalElement) {
      this.close()
    }
  }

  modalElement() {
    return document.getElementById("snapshot-modal")
  }
}
