# 预览指南 - iPhone 16 比例

## 方法 1：使用 Chrome/Safari 浏览器开发者工具（推荐）

### Chrome 浏览器：

1. **打开页面**
   ```
   http://localhost:5173/login
   ```

2. **打开开发者工具**
   - 按 `F12` 或 `Cmd+Option+I` (Mac) / `Ctrl+Shift+I` (Windows)
   - 或者右键点击页面 → "检查"

3. **切换到设备模拟模式**
   - 点击工具栏左上角的设备图标 📱
   - 或按快捷键：`Cmd+Shift+M` (Mac) / `Ctrl+Shift+M` (Windows)

4. **选择 iPhone 16**
   - 在设备下拉菜单中选择 "iPhone 16"
   - 如果没有，选择 "iPhone 14 Pro" 或自定义尺寸

5. **自定义尺寸（如果没有 iPhone 16）**
   - 点击设备下拉菜单 → "Edit..."
   - 添加新设备：
     - Device name: iPhone 16
     - Width: 393
     - Height: 852
     - Device pixel ratio: 3
     - User agent: iPhone

### Safari 浏览器（Mac）：

1. **启用开发者菜单**
   - Safari → 设置 → 高级 → 勾选"显示网页检查器"

2. **打开页面并模拟设备**
   - 打开页面后，按 `Cmd+Option+I` 打开开发者工具
   - 点击"响应式设计模式"图标
   - 选择 "iPhone" 或自定义尺寸

---

## 方法 2：在外部浏览器中打开

1. **启动开发服务器**
   ```bash
   cd octa-web
   npm run dev
   ```

2. **在浏览器中打开**
   - Chrome: `http://localhost:5173/login`
   - Safari: `http://localhost:5173/login`

3. **使用浏览器缩放**
   - 按 `Cmd+0` (Mac) / `Ctrl+0` (Windows) 重置缩放
   - 按 `Cmd+-` 缩小到合适的比例查看

---

## 方法 3：在手机上预览（最准确）

1. **确保手机和电脑在同一 WiFi**

2. **查看开发服务器输出**
   ```bash
   npm run dev
   ```
   会显示类似：
   ```
   ➜  Local:   http://localhost:5173/
   ➜  Network: http://192.168.1.196:5173/
   ```

3. **在手机浏览器输入 Network 地址**
   - 例如：`http://192.168.1.196:5173/login`

---

## 方法 4：调整代码中的最大宽度

如果你想在桌面浏览器中看到移动端的固定宽度效果：

1. 代码中已经设置了 `--app-max-width: 480px`
2. 在桌面浏览器中打开页面，窗口会自动限制为 480px 宽度
3. 但这不是 iPhone 16 的精确比例，只是固定宽度

---

## 推荐的预览方式

**最佳方式**：使用 Chrome 开发者工具的设备模拟功能
- 最接近真实设备
- 可以切换不同设备
- 可以测试横屏/竖屏
- 可以查看触摸目标大小

**最准确方式**：在真实 iPhone 上预览
- 100% 真实效果
- 可以测试触摸交互
- 可以测试性能

