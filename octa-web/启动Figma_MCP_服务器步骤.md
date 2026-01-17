# 启动 Figma MCP 服务器 - 快速指南

## ✅ 发现

已找到 Cursor 的 MCP 配置：

```json
{
  "mcpServers": {
    "Figma Desktop": {
      "url": "http://127.0.0.1:3845/mcp",
      "headers": {}
    }
  }
}
```

配置显示 Figma Desktop MCP 服务器应该运行在 `http://127.0.0.1:3845/mcp`

## 🔍 当前状态检查

### 检查 1：服务器端点

MCP 配置的端点是 `/mcp`，但图片资源的路径是 `/assets/xxx.png`。

可能需要：
- 服务器同时提供 `/mcp` (MCP API) 和 `/assets/` (资源文件)
- 或者需要重新配置服务器路径

### 检查 2：Figma Desktop 应用

检查 Figma Desktop 应用是否正在运行：

```bash
ps aux | grep -i figma
```

如果看到 `FigmaAgent.app` 在运行，说明 Figma Desktop 正在运行。

## 🚀 启动步骤

### 方式 1：确保 Figma Desktop 应用运行

Figma Desktop MCP 服务器通常需要 Figma Desktop 应用在运行：

1. **打开 Figma Desktop 应用**
   - 确保 Figma Desktop 已安装并运行
   - 如果没有，从 https://www.figma.com/downloads/ 下载安装

2. **登录 Figma Desktop**
   - 使用您的 Figma 账号登录

3. **重启 Cursor**
   - 关闭并重新打开 Cursor 编辑器
   - Cursor 会自动检测并连接 Figma Desktop MCP 服务器

### 方式 2：检查 Cursor MCP 连接状态

1. **打开 Cursor 设置**
   - `Cmd + ,` (Mac) 或 `Ctrl + ,` (Windows/Linux)

2. **检查 MCP 服务器状态**
   - 进入 `Features` → `MCP`
   - 查看 "Figma Desktop" 服务器是否显示为"已连接"或"运行中"

3. **查看 MCP 日志**
   - 检查 Cursor 的输出面板
   - 查找 MCP 相关的错误或警告信息

### 方式 3：手动重启 MCP 服务器

1. **重启 Cursor 编辑器**
   - 完全退出 Cursor（不只是关闭窗口）
   - 重新打开 Cursor

2. **检查服务器状态**
   ```bash
   # 检查端口是否被占用
   lsof -i :3845
   
   # 测试服务器是否可以访问
   curl -I http://127.0.0.1:3845/mcp
   ```

## 🔧 故障排除

### 问题 1：服务器无法连接

**可能原因**：
- Figma Desktop 应用未运行
- Cursor MCP 插件未正确加载
- 端口被其他程序占用

**解决方案**：
1. 确保 Figma Desktop 应用正在运行
2. 重启 Cursor 编辑器
3. 检查防火墙设置

### 问题 2：端点路径不匹配

**可能原因**：
- MCP 服务器端点是 `/mcp`
- 但图片资源可能在 `/assets/` 路径

**解决方案**：
1. 检查实际的图片 URL 路径
2. 可能需要调整代码中的路径
3. 或者重新配置 MCP 服务器

### 问题 3：Figma Desktop 未登录

**解决方案**：
1. 打开 Figma Desktop 应用
2. 确保已登录您的 Figma 账号
3. 重新启动 Cursor

## ⚡ 快速验证

运行以下命令验证服务器是否正常：

```bash
# 检查端口
lsof -i :3845

# 测试 MCP 端点
curl -I http://127.0.0.1:3845/mcp

# 测试资源端点（如果可用）
curl -I http://127.0.0.1:3845/assets/test
```

如果这些命令返回 HTTP 状态码（如 200 或 404），说明服务器在运行。

## 📚 需要帮助？

如果仍然无法启动服务器，请提供：

1. **Figma Desktop 是否正在运行？**
2. **Cursor MCP 设置中的状态是什么？**
3. **Cursor 输出日志中有什么错误？**
4. **运行 `lsof -i :3845` 的输出是什么？**
