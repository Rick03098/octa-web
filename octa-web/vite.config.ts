import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import basicSsl from '@vitejs/plugin-basic-ssl'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    basicSsl(), // 启用 HTTPS，移动端权限 API 需要
  ],
  server: {
    host: '0.0.0.0', // 允许局域网访问
    port: 5173,
    strictPort: false, // 如果端口被占用，自动尝试下一个端口
    https: true, // 启用 HTTPS
  },
  preview: {
    host: '0.0.0.0', // 预览模式也允许局域网访问
    port: 4173,
  },
})
