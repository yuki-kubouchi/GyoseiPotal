# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# アセットのデバッグを有効にする
Rails.application.config.assets.debug = true

# アセットのダイジェストを有効にする
Rails.application.config.assets.digest = true

# アセットのコンパイルを有効にする
Rails.application.config.assets.compile = true

# プリコンパイル対象のアセットを指定
Rails.application.config.assets.precompile += %w( application.css )

# フォントのパスを追加
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
Rails.application.config.assets.precompile += %w( .ttf )
