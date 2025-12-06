// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"
import "jquery"
import "@nathanvda/cocoon"
import { initInvoices } from "./invoices"

// グローバルにcocoonを利用可能にする
window.Cocoon = window.Cocoon || {};

// アプリケーション全体の初期化
function initializeApplication() {
  // ActiveStorageの初期化
  ActiveStorage.start();
  
  // 請求書フォームの初期化
  if (document.querySelector('.invoice-form')) {
    initInvoices();
  }
}

// ドキュメントロード時とTurboのページ遷移時に初期化
document.addEventListener('DOMContentLoaded', initializeApplication);
document.addEventListener('turbo:load', initializeApplication);
document.addEventListener('turbo:render', initializeApplication);

// 即時実行もサポート
if (document.readyState !== 'loading') {
  initializeApplication();
}

// グラフ初期化関数はダッシュボードのビューで直接定義