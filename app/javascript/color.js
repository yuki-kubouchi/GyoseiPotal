// 簡易的なカラーユーティリティ
const Color = {
  // 16進数カラーコードをRGBに変換
  hexToRgb: function(hex) {
    // #を削除
    hex = hex.replace(/^#/, '');
    
    // 3桁の場合は6桁に変換
    if (hex.length === 3) {
      hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }
    
    // RGBに変換
    const num = parseInt(hex, 16);
    return {
      r: num >> 16,
      g: (num >> 8) & 255,
      b: num & 255,
      a: 1
    };
  },
  
  // RGBを16進数カラーコードに変換
  rgbToHex: function(r, g, b) {
    return '#' + [r, g, b].map(x => {
      const hex = x.toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    }).join('');
  },
  
  // 色を薄くする
  lighten: function(color, percent) {
    const rgb = this.hexToRgb(color);
    const t = percent || 0;
    
    return this.rgbToHex(
      Math.round(rgb.r + (255 - rgb.r) * t / 100),
      Math.round(rgb.g + (255 - rgb.g) * t / 100),
      Math.round(rgb.b + (255 - rgb.b) * t / 100)
    );
  },
  
  // 色を濃くする
  darken: function(color, percent) {
    const rgb = this.hexToRgb(color);
    const t = percent || 0;
    
    return this.rgbToHex(
      Math.max(0, Math.round(rgb.r * (100 - t) / 100)),
      Math.max(0, Math.round(rgb.g * (100 - t) / 100)),
      Math.max(0, Math.round(rgb.b * (100 - t) / 100))
    );
  },
  
  // アルファ値を適用
  alpha: function(color, alpha) {
    const rgb = this.hexToRgb(color);
    return `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${alpha})`;
  }
};

// デフォルトエクスポートとして公開
export default Color;
