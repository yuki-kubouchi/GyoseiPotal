import 'cocoon-js';

document.addEventListener('turbolinks:load', function() {
  // フォーム内の動的計算
  const calculateAmount = (item) => {
    const quantity = parseFloat(item.querySelector('.quantity-field').value) || 0;
    const unitPrice = parseFloat(item.querySelector('.unit-price-field').value) || 0;
    const amount = quantity * unitPrice;
    item.querySelector('.amount-field').value = amount.toFixed(0);
    return amount;
  };

  const updateTotals = () => {
    let subtotal = 0;
    document.querySelectorAll('.nested-fields:not([style*="display: none"])').forEach(item => {
      subtotal += calculateAmount(item);
    });

    const taxRate = parseFloat(document.querySelector('#invoice_tax_rate').value) || 0;
    const taxAmount = subtotal * (taxRate / 100);
    const total = subtotal + taxAmount;

    // 必要に応じて合計を表示する要素を更新
    // 例: document.querySelector('.subtotal-amount').textContent = subtotal.toLocaleString();
  };

  // 数量または単価が変更されたときに合計を更新
  document.addEventListener('change', function(e) {
    if (e.target.matches('.quantity-field, .unit-price-field')) {
      const item = e.target.closest('.nested-fields');
      if (item) {
        calculateAmount(item);
        updateTotals();
      }
    }
  });

  // 税率が変更されたときに合計を更新
  document.addEventListener('change', function(e) {
    if (e.target.matches('#invoice_tax_rate')) {
      updateTotals();
    }
  });

  // 単価の上下ボタン機能（1000円単位）
  document.addEventListener('click', function(e) {
    if (e.target.closest('.price-btn-up')) {
      const item = e.target.closest('.nested-fields');
      const unitPriceField = item.querySelector('.unit-price-field');
      const currentValue = parseFloat(unitPriceField.value) || 0;
      unitPriceField.value = (currentValue + 1000).toFixed(0);
      unitPriceField.dispatchEvent(new Event('change', { bubbles: true }));
      e.preventDefault();
    }
    if (e.target.closest('.price-btn-down')) {
      const item = e.target.closest('.nested-fields');
      const unitPriceField = item.querySelector('.unit-price-field');
      const currentValue = parseFloat(unitPriceField.value) || 0;
      if (currentValue >= 1000) {
        unitPriceField.value = (currentValue - 1000).toFixed(0);
        unitPriceField.dispatchEvent(new Event('change', { bubbles: true }));
      }
      e.preventDefault();
    }
  });

  // 初期ロード時に合計を計算
  updateTotals();
});