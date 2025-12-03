// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"
import "jquery"
import "@nathanvda/cocoon"
import "chartkick"
import "chart.js/auto"

// Invoice-specific behaviors (amount calc, +/- buttons)
import "./invoices"

// グローバルにcocoonを利用可能にする
window.Cocoon = window.Cocoon || {};

// cocoonの初期化
ActiveStorage.start()

// Stimulus controllers are loaded via the importmap "controllers" entry.
// The legacy webpack helpers (require.context / stimulus-webpack-helpers)
// are not available when using importmap-rails, so we avoid them here.

