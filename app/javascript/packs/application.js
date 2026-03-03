// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "flowbite/dist/flowbite.turbo.js";
import "../controllers/index.js"
import tippy from "tippy.js"
import "../assets/pagy.js"

import "../../stylesheets/application.css"

document.addEventListener("turbo:load", () => {
  tippy("[data-tippy-content]")
  Pagy.init()
})
