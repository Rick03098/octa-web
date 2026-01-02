# 手机预览指南

## 方法 1：局域网访问（推荐，最简单）

### 步骤：

1. **确保手机和电脑在同一 WiFi 网络**

2. **启动开发服务器**
   ```bash
   npm run dev
   ```

3. **查看终端输出的地址**
   启动后会显示类似：
   ```
   ➜  Local:   http://localhost:5173/
   ➜  Network: http://192.168.1.196:5173/
   ```

4. **在手机上打开浏览器**
   - 输入 `Network` 显示的地址（例如：`http://192.168.1.196:5173/`）
   - 或者扫描终端显示的二维码（如果支持）

### 如果看不到 Network 地址：

检查防火墙设置：
- **macOS**: 系统设置 → 网络 → 防火墙 → 允许 Vite 通过防火墙
- **Windows**: 控制面板 → Windows Defender 防火墙 → 允许应用通过防火墙

---

## 方法 2：使用 ngrok（适合远程测试）

如果需要在外网访问（比如给不在同一 WiFi 的朋友看）：

1. **安装 ngrok**
   ```bash
   # macOS
   brew install ngrok
   
   # 或访问 https://ngrok.com/download 下载
   ```

2. **启动开发服务器**
   ```bash
   npm run dev
   ```

3. **在另一个终端启动 ngrok**
   ```bash
   ngrok http 5173
   ```

4. **使用 ngrok 提供的地址**
   ngrok 会显示类似：
   ```
   Forwarding  https://xxxx-xx-xx-xx-xx.ngrok.io -> http://localhost:5173
   ```
   在手机上访问这个 `https://` 地址即可

---

## 方法 3：使用手机浏览器开发者工具

### Chrome DevTools（推荐）

1. **在电脑 Chrome 中打开**
   ```
   chrome://inspect/#devices
   ```

2. **连接手机**
   - 用 USB 连接手机
   - 在手机上启用"USB 调试"
   - 在 Chrome 中点击"Port forwarding"，添加端口 `5173`

3. **访问**
   - 在手机上打开 Chrome
   - 访问 `localhost:5173`

---

## 方法 4：构建后预览（生产环境测试）

1. **构建项目**
   ```bash
   npm run build
   ```

2. **预览构建结果**
   ```bash
   npm run preview
   ```

3. **使用局域网地址访问**
   访问 `http://你的IP:4173`

---

## 常见问题

### Q: 手机访问显示"无法连接"
- ✅ 检查手机和电脑是否在同一 WiFi
- ✅ 检查防火墙是否允许端口 5173
- ✅ 尝试关闭电脑的 VPN（如果有）

### Q: 页面显示不正常
- ✅ 确保使用手机浏览器（Safari/Chrome）
- ✅ 清除浏览器缓存
- ✅ 检查控制台是否有错误

### Q: 动画不播放
- ✅ 确保 `/public/videos/login-background-video.json` 文件存在
- ✅ 检查浏览器控制台的网络请求是否成功

---

## 快速命令

```bash
# 启动开发服务器（自动显示局域网地址）
npm run dev

# 查看本机 IP（macOS/Linux）
ifconfig | grep "inet " | grep -v 127.0.0.1

# 查看本机 IP（Windows）
ipconfig
```

---

## 你的当前 IP

根据检测，你的局域网 IP 是：**192.168.1.196**

启动 `npm run dev` 后，在手机上访问：
**http://192.168.1.196:5173**

