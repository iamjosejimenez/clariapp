// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import tippy from 'tippy.js';
import "../stylesheets/application.css"

document.addEventListener("turbo:load", () => {
  tippy('[data-tippy-content]');
});
