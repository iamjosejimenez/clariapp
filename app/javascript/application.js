// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import tippy from 'tippy.js';
import 'tippy.js/dist/tippy.css';

document.addEventListener("DOMContentLoaded", () => {
  tippy('[data-tippy-content]');
});
