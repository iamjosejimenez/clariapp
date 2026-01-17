// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "../controllers/index.js"
import tippy from 'tippy.js';
import "../../stylesheets/application.css"
import "../assets/pagy.js";

document.addEventListener("turbo:load", () => {
  tippy('[data-tippy-content]');
  Pagy.init();
});
