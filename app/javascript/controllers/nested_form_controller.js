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
    
    // 動的に追加された要素に対してイベントを再設定
    const newItem = this.addButtonTarget.previousElementSibling
    if (newItem) {
      // 金額計算を初期化
      if (typeof calculateAmount === 'function') {
        calculateAmount(newItem)
      }
      if (typeof updateTotals === 'function') {
        updateTotals()
      }
    }
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
