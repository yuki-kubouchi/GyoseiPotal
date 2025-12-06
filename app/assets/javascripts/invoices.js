// 請求書関連のJavaScript機能をここに実装

document.addEventListener('DOMContentLoaded', function() {
  console.log('invoices.js loaded');
  
  // 金額計算機能
  function calculateAmounts() {
    const amountFields = document.querySelectorAll('.amount-field');
    amountFields.forEach(field => {
      const row = field.closest('tr');
      if (row) {
        const quantity = parseFloat(row.querySelector('.quantity-field')?.value) || 0;
        const unitPrice = parseFloat(row.querySelector('.unit-price-field')?.value) || 0;
        field.value = (quantity * unitPrice).toLocaleString();
      }
    });
  }

  // イベントリスナーを設定
  document.addEventListener('change', function(e) {
    if (e.target.matches('.quantity-field, .unit-price-field')) {
      calculateAmounts();
    }
  });

  // 初期計算を実行
  calculateAmounts();
});
