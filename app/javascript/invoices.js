// Invoice form behaviors: calculate amounts, price +/- buttons (1000 yen)
// This module is imported by application.js and runs on every Turbo load.

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
  document.querySelectorAll('.nested-fields:not([style*="display: none"])').forEach(item => {
    subtotal += calculateAmount(item);
  });
  // update subtotal display if present
  const subtotalEl = document.querySelector('.subtotal-amount');
  if (subtotalEl) subtotalEl.textContent = Math.round(subtotal).toLocaleString();
  
  // Update tax if needed
  const taxRate = parseFloat(document.querySelector('#invoice_tax_rate')?.value) || 0;
  const taxAmount = subtotal * (taxRate / 100);
  const total = subtotal + taxAmount;
  
  const taxEl = document.querySelector('.tax-amount');
  const totalEl = document.querySelector('.total-amount');
  
  if (taxEl) taxEl.textContent = Math.round(taxAmount).toLocaleString();
  if (totalEl) totalEl.textContent = Math.round(total).toLocaleString();
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
  // Price up/down buttons (1000 yen step)
  const upBtn = e.target.closest('.price-btn-up');
  const downBtn = e.target.closest('.price-btn-down');
  
  if (upBtn || downBtn) {
    e.preventDefault();
    const btn = upBtn || downBtn;
    const item = btn.closest('.nested-fields');
    if (!item) return;
    
    const unitPriceField = item.querySelector('.unit-price-field');
    const current = parseFloat(unitPriceField?.value) || 0;
    const step = 1000;
    
    if (upBtn) {
      unitPriceField.value = (current + step).toFixed(0);
    } else if (downBtn) {
      unitPriceField.value = Math.max(0, current - step).toFixed(0);
    }
    
    // Trigger change event to update amounts
    unitPriceField.dispatchEvent(new Event('change', { bubbles: true }));
  }
};

// Initialize the invoice form
const initInvoiceForm = () => {
  // フォームが存在する場合のみ初期化
  if (!document.querySelector('.nested-fields')) return;
  
  // Remove existing event listeners to prevent duplicates
  document.removeEventListener('change', handleChange);
  document.removeEventListener('click', handleClick);
  
  // Add event listeners
  document.addEventListener('change', handleChange);
  document.addEventListener('click', handleClick);
  
  // Initialize totals for all existing items
  document.querySelectorAll('.nested-fields').forEach(item => {
    calculateAmount(item);
  });
  updateTotals();
};

// Debug logging
console.log('invoices.js loaded');

// Event listener for cocoon
const handleCocoonInsert = function(e) {
  console.log('cocoon:after-insert triggered', e.detail[0]);
  const inserted = e.detail[0];
  // initialize amount
  calculateAmount(inserted);
  updateTotals();};

const handleCocoonRemove = function() {
  console.log('cocoon:after-remove triggered');
  updateTotals();};

// Initialize everything when the DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  console.log('DOMContentLoaded - initializing invoice form');
  initInvoiceForm();
  
  // Add cocoon event listeners
  document.removeEventListener('cocoon:after-insert', handleCocoonInsert);
  document.removeEventListener('cocoon:after-remove', handleCocoonRemove);
  
  document.addEventListener('cocoon:after-insert', handleCocoonInsert);
  document.addEventListener('cocoon:after-remove', handleCocoonRemove);
});

// Also initialize on Turbo navigation
document.addEventListener('turbo:load', function() {
  console.log('turbo:load - initializing invoice form');
  initInvoiceForm();
});
document.addEventListener('turbo:render', initInvoiceForm);

// Also initialize now in case the script loads after turbo:load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initInvoiceForm);
} else {
  initInvoiceForm();
}