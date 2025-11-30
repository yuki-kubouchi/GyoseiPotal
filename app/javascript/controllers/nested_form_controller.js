// app/javascript/controllers/nested_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addButton", "template"]

  connect() {
    this.wrapperClass = this.data.get("wrapperClass") || "nested-fields"
  }

  add(e) {
    e.preventDefault()
    
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.addButtonTarget.insertAdjacentHTML('beforebegin', content)
  }

  remove(e) {
    e.preventDefault()
    
    const wrapper = e.target.closest(`.${this.wrapperClass}`)
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      wrapper.style.display = 'none'
      wrapper.querySelector("input[name*='_destroy']").value = 1
    }
  }
}
