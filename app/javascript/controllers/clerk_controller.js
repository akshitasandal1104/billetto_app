import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["userButton", "signIn"]

  async connect() {
    await window.Clerk?.load()
    this.render()
  }

  render() {
    const clerk = window.Clerk
    if (!clerk) return

    if (clerk.user) {
      if (this.hasUserButtonTarget) {
        clerk.mountUserButton(this.userButtonTarget)
      }
      if (this.hasSignInTarget) {
        this.signInTarget.hidden = true
      }
    } else {
      if (this.hasSignInTarget) {
        this.signInTarget.hidden = false
      }
    }
  }

  signIn() {
    window.Clerk?.openSignIn()
  }

  signOut() {
    window.Clerk?.signOut(() => window.location.reload())
  }
}
