// Invoice form behaviors: calculate amounts, price +/- buttons (1000 yen)
// This module is imported by application.js and runs on every Turbo load.

document.addEventListener('turbo:load', () => {
  // calculate amount for a nested-fields element
  const calculateAmount = (item) => {
    const quantityInput = item.querySelector('.quantity-field') || item.querySelector('input[name*="[quantity]"]');
    const quantity = parseFloat(quantityInput && quantityInput.value) || 1;
    const unitPrice = parseFloat(item.querySelector('.unit-price-field')?.value) || 0;
    const amount = quantity * unitPrice;
    const amountField = item.querySelector('.amount-field');
    if (amountField) {
      // format without decimals
      amountField.value = Math.round(amount).toLocaleString();
    }
    return amount;
  };

  const updateTotals = () => {
    let subtotal = 0;
    document.querySelectorAll('.nested-fields:not([style*="display: none"])').forEach(item => {
      subtotal += calculateAmount(item);
    });
    // update subtotal display if present
    const subtotalEl = document.querySelector('.subtotal-amount');
    if (subtotalEl) subtotalEl.textContent = Math.round(subtotal).toLocaleString();
  };

  // handle change events for unit price or quantity
  document.addEventListener('change', function(e) {
    if (e.target.matches('.unit-price-field') || e.target.matches('input[name*="[quantity]"]')) {
      const item = e.target.closest('.nested-fields');
      if (item) {
        calculateAmount(item);
        updateTotals();
      }
    }

    if (e.target.matches('#invoice_tax_rate')) {
      updateTotals();
    }
  });

  // price up/down buttons (1000 yen step)
  document.addEventListener('click', function(e) {
    const upBtn = e.target.closest('.price-btn-up');
    const downBtn = e.target.closest('.price-btn-down');
    if (upBtn || downBtn) {
      const btn = upBtn || downBtn;
      const item = btn.closest('.nested-fields');
      if (!item) return;
      const unitPriceField = item.querySelector('.unit-price-field');
      const current = parseFloat(unitPriceField.value) || 0;
      const step = 1000;
      if (upBtn) {
        unitPriceField.value = (current + step).toFixed(0);
      } else if (downBtn) {
        unitPriceField.value = Math.max(0, current - step).toFixed(0);
      }
      unitPriceField.dispatchEvent(new Event('change', { bubbles: true }));
      e.preventDefault();
    }
  });

  // When cocoon inserts a new nested item, recalc totals
  document.addEventListener('cocoon:after-insert', function(e) {
    const inserted = e.detail[0];
    // initialize amount
    calculateAmount(inserted);
    updateTotals();
  });

  // When cocoon removes an item
  document.addEventListener('cocoon:after-remove', function() {
    updateTotals();
  });

  // Initial calculation on load
  updateTotals();
});
