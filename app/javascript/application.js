// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// モジュールをインポート
import { Turbo } from "@hotwired/turbo-rails"
import Color from "./color.js"
import * as ActiveStorage from "@rails/activestorage"
import "jquery"
import "@nathanvda/cocoon"
import Chart from "chart.js/auto"
import Chartkick from "chartkick"
import initInvoices from "invoices"

// Chart.jsをChartkickに登録
Chartkick.addAdapter(Chart)

// コントローラーをインポート
import "./controllers"

// グローバルに必要な変数を設定
window.Turbo = Turbo
window.Color = Color

// グローバルにcocoonを利用可能にする
window.Cocoon = window.Cocoon || {}

// ActiveStorageの初期化
ActiveStorage.start()

// アプリケーション全体の初期化
function initializeApplication() {
  // 請求書フォームの初期化
  if (document.querySelector('.invoice-form')) {
    initInvoices();
  }
}

// ドキュメントロード時とTurboのページ遷移時に初期化
document.addEventListener('DOMContentLoaded', initializeApplication);
document.addEventListener('turbo:load', initializeApplication);

// 即時実行もサポート
if (document.readyState !== 'loading') {
  initializeApplication();
}

// グラフ初期化関数はダッシュボードのビューで直接定義