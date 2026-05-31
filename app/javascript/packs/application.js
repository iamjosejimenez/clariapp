// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "flowbite/dist/flowbite.turbo.js";
import "../controllers/index.js"
import tippy from "tippy.js"
import "../assets/pagy.js"
import * as Sentry from "@sentry/browser";

import "../../stylesheets/application.css"

document.addEventListener("turbo:load", () => {
  tippy("[data-tippy-content]")
  Pagy.init()

  const sentryDsn = document.querySelector('meta[name="sentry-dsn"]')?.content
  const appRelease = document.querySelector('meta[name="app-release"]')?.content
  const sentryEnvironment = document.querySelector('meta[name="sentry-environment"]')?.content

  if (sentryEnvironment !== "production" || !sentryDsn) return

  Sentry.init({
    dsn: sentryDsn,
    // Adds request headers and IP for users, for more info visit:
    // https://docs.sentry.io/platforms/javascript/configuration/options/#sendDefaultPii
    sendDefaultPii: true,
    // Alternatively, use `process.env.npm_package_version` for a dynamic release version
    // if your build tool supports it.
    release: appRelease,
  });
});
