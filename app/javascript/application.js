// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "https://unpkg.com/@kurkle/color@0.4.5/dist/color.umd.js"
import "chart.js"
import Chartkick from "chartkick"
import "@hotwired/turbo-rails"
import "controllers"
import * as ActiveStorage from "@rails/activestorage"
import "jquery"
import "@nathanvda/cocoon"

// Invoice-specific behaviors (amount calc, +/- buttons)
import "./invoices"

// グローバルにcocoonを利用可能にする
window.Cocoon = window.Cocoon || {};

// cocoonの初期化
ActiveStorage.start()