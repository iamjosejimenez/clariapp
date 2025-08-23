// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import tippy from 'tippy.js';

document.addEventListener("turbo:load", () => {
  tippy('[data-tippy-content]');
});
