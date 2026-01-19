/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // 从 iOS Colors.swift 提取的颜色
        primary: {
          light: '#DBECFF',
          DEFAULT: '#4A6BB8',
        },
      },
      fontFamily: {
        serif: ['Noto Serif SC', 'Source Han Serif SC', 'serif'],
      },
    },
  },
  plugins: [],
}


