// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

document.addEventListener("turbo:load", () => {
  const btn = document.getElementById("rw-calendar-toggle");
  const menu = document.getElementById("rw-calendar-menu");

  if (!btn || !menu) return;

  btn.addEventListener("click", (e) => {
    e.stopPropagation();
    menu.classList.toggle("is-open");
    btn.setAttribute(
      "aria-expanded",
      menu.classList.contains("is-open")
    );
  });

  document.addEventListener("click", () => {
    menu.classList.remove("is-open");
    btn.setAttribute("aria-expanded", "false");
  });

  menu.addEventListener("click", (e) => {
    e.stopPropagation();
  });
});
