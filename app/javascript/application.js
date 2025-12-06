// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"
import "jquery"
import "@nathanvda/cocoon"
// Chart.jsをグローバルに設定
import Chart from 'chart.js/auto';
window.Chart = Chart;
import "chartkick"

// Invoice-specific behaviors (amount calc, +/- buttons)
import "./invoices"

// グローバルにcocoonを利用可能にする
window.Cocoon = window.Cocoon || {};

// cocoonの初期化
ActiveStorage.start()

// グラフ初期化関数はダッシュボードのビューで直接定義