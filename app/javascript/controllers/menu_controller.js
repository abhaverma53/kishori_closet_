import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "search"]

  toggle() {
    this.panelTarget.classList.toggle("hidden")
  }

  toggleSearch() {
    this.searchTarget.classList.toggle("hidden")
    if (!this.searchTarget.classList.contains("hidden")) {
      const input = this.searchTarget.querySelector("input")
      if (input) input.focus()
    }
  }
}
