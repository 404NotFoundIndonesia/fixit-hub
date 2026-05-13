import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "input"]

  connect() {
    this.currentUserId = document.body.dataset.currentUserId
    this.applyMineTheirs()
    this.scrollToBottom()
  }

  listTargetConnected() {
    this.applyMineTheirs()
    this.scrollToBottom()
  }

  applyMineTheirs() {
    if (!this.hasListTarget || !this.currentUserId) return
    this.listTarget.querySelectorAll(".message[data-sender-id]").forEach(el => {
      el.classList.remove("message--mine", "message--theirs")
      el.classList.add(
        el.dataset.senderId === this.currentUserId ? "message--mine" : "message--theirs"
      )
    })
  }

  scrollToBottom() {
    if (this.hasListTarget) {
      this.listTarget.scrollTop = this.listTarget.scrollHeight
    }
  }
}
