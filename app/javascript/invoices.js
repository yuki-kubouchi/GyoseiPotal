// Invoice form behaviors: calculate amounts, price +/- buttons (1000 yen)
// This module is imported by application.js and runs on every Turbo load.

console.log('=== invoices.js loaded (NEW VERSION 2025-12-07) ===');

let eventListenersAdded = false;

// Calculate amount for a nested-fields element
const calculateAmount = (item) => {
  const quantityInput = item.querySelector('.quantity-field') || item.querySelector('input[name*="[quantity]"]');
  const quantity = parseFloat(quantityInput?.value) || 1;
  const unitPrice = parseFloat(item.querySelector('.unit-price-field')?.value) || 0;
  const amount = quantity * unitPrice;
  const amountField = item.querySelector('.amount-field');
  if (amountField) {
    // format without decimals
    amountField.value = Math.round(amount).toLocaleString();
  }
  return amount;
};

// Update all totals
const updateTotals = () => {
  let subtotal = 0;
  const visibleItems = document.querySelectorAll('.nested-fields:not([style*="display: none"])');
  
  visibleItems.forEach(item => {
    const destroyField = item.querySelector('.destroy-field');
    // 削除予定の項目はスキップ
    if (destroyField && destroyField.value === '1') return;
    
    subtotal += calculateAmount(item);
  });
  
  // update subtotal display if present
  const subtotalEl = document.querySelector('.subtotal-amount');
  if (subtotalEl) {
    subtotalEl.textContent = Math.round(subtotal).toLocaleString();
  }
  
  // Update tax if needed
  const taxRate = parseFloat(document.querySelector('#invoice_tax_rate')?.value) || 0;
  const taxAmount = subtotal * (taxRate / 100);
  const total = subtotal + taxAmount;
  
  const taxEl = document.querySelector('.tax-amount');
  const totalEl = document.querySelector('.total-amount');
  
  if (taxEl) taxEl.textContent = Math.round(taxAmount).toLocaleString();
  if (totalEl) totalEl.textContent = Math.round(total).toLocaleString();
  
  console.log('Totals updated:', { subtotal, taxRate, taxAmount, total });
};

// Handle change events
const handleChange = (e) => {
  if (e.target.matches('.unit-price-field, input[name*="[quantity]"], .quantity-field')) {
    const item = e.target.closest('.nested-fields');
    if (item) {
      calculateAmount(item);
      updateTotals();
    }
  }

  if (e.target.matches('#invoice_tax_rate')) {
    updateTotals();
  }
};

// Handle click events
const handleClick = (e) => {
  // ボタンまたはその子要素(SVG)がクリックされた場合
  const upButton = e.target.closest('.price-btn-up');
  const downButton = e.target.closest('.price-btn-down');
  
  if (upButton) {
    e.preventDefault();
    const container = upButton.closest('.flex.gap-1').parentElement;
    const input = container.querySelector('input.unit-price-field');
    if (input) {
      const currentValue = parseFloat(input.value) || 0;
      input.value = currentValue + 1000;
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
  } else if (downButton) {
    e.preventDefault();
    const container = downButton.closest('.flex.gap-1').parentElement;
    const input = container.querySelector('input.unit-price-field');
    if (input) {
      const currentValue = parseFloat(input.value) || 0;
      input.value = Math.max(0, currentValue - 1000);
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
  }
};

// Initialize the invoice form
const initInvoiceForm = () => {
  const form = document.querySelector('.invoice-form');
  if (!form) return;
  
  console.log('Initializing invoice form');
  
  // 初期合計を計算
  updateTotals();
};

// Event listener for cocoon
const handleCocoonInsert = (e) => {
  console.log('Cocoon insert event');
  updateTotals();
  // 新しい行の最初の入力フィールドにフォーカスを当てる
  const newItem = e.detail[0];
  if (newItem) {
    const firstInput = newItem.querySelector('input:not([type="hidden"]), select, textarea');
    if (firstInput) firstInput.focus();
  }
};

const handleCocoonRemove = () => {
  console.log('Cocoon remove event');
  updateTotals();
};

// モジュールとしてエクスポート
export function initInvoices() {
  console.log('initInvoices called');
  
  // イベントリスナーを1回だけ登録
  if (!eventListenersAdded) {
    console.log('Adding event listeners');
    document.addEventListener('change', handleChange);
    document.addEventListener('click', handleClick);
    document.addEventListener('cocoon:after-insert', handleCocoonInsert);
    document.addEventListener('cocoon:before-remove', handleCocoonRemove);
    eventListenersAdded = true;
  }
  
  // フォームを初期化
  initInvoiceForm();
}

// デフォルトエクスポート
export default initInvoices;