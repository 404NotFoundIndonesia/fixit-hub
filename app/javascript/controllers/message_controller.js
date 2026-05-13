import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "input"]

  connect() {
    this.scrollToBottom()
  }

  // Called whenever Turbo appends a new message to the list
  listTargetConnected() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    if (this.hasListTarget) {
      this.listTarget.scrollTop = this.listTarget.scrollHeight
    }
  }
}
