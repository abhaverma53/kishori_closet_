import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  increase() {
    this.inputTarget.value = Math.max(1, Number(this.inputTarget.value || 1) + 1)
  }

  decrease() {
    this.inputTarget.value = Math.max(1, Number(this.inputTarget.value || 1) - 1)
  }
}
