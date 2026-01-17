# 如何启动 localhost:3845 Figma MCP 服务器

## 🔍 理解问题

`localhost:3845` 的 Figma MCP 服务器**不是**项目代码的一部分，而是 **Cursor 编辑器的 MCP (Model Context Protocol) 功能**提供的服务。

## 📋 Figma MCP 服务器的来源

Figma MCP 服务器通常通过以下方式提供：

1. **Cursor 的 MCP 功能**（自动运行）
   - 如果配置了 Figma MCP，Cursor 会自动启动服务器
   - 服务器地址通常是 `localhost:3845`

2. **独立的 Figma MCP 服务**（如果存在）
   - 需要手动启动
   - 可能需要配置和安装

## ✅ 检查步骤

### 步骤 1：检查 Cursor MCP 配置

1. 打开 **Cursor 设置**：
   - `Cmd + ,` (Mac) 或 `Ctrl + ,` (Windows/Linux)
   - 或菜单：`Cursor` → `Settings` → `Features` → `MCP`

2. 查找 **Figma MCP** 相关的配置：
   - 是否已启用 Figma MCP
   - 服务器端口是否为 `3845`
   - 是否需要 API Token 或认证

### 步骤 2：检查服务器是否自动运行

```bash
# 检查端口是否被占用
lsof -i :3845

# 或者
netstat -an | grep 3845
```

如果端口被占用，说明服务器可能在运行，但可能绑定到了不同的地址。

### 步骤 3：检查 Cursor 日志

查看 Cursor 的输出日志或开发者工具，看是否有 MCP 服务器的错误信息。

### 步骤 4：验证服务器访问

```bash
# 测试服务器是否可以访问
curl -I http://localhost:3845/assets/test

# 或者在浏览器中访问
open http://localhost:3845/assets/test
```

## 🔧 可能的原因和解决方案

### 原因 1：MCP 未配置

**解决方案**：
1. 打开 Cursor 设置
2. 进入 MCP 配置
3. 添加或启用 Figma MCP 服务器
4. 配置必要的认证信息（如 Figma API Token）

### 原因 2：MCP 服务器未自动启动

**解决方案**：
1. 重启 Cursor 编辑器
2. 检查 MCP 服务器的状态
3. 查看 Cursor 的输出日志

### 原因 3：端口冲突

**解决方案**：
1. 检查 `3845` 端口是否被其他程序占用
2. 如果有冲突，修改 MCP 配置使用其他端口

### 原因 4：需要手动启动独立服务器

如果项目中有独立的 Figma MCP 服务器代码：

```bash
# 查找服务器启动脚本
find . -name "*mcp*" -o -name "*figma*server*"

# 可能需要安装依赖
npm install  # 或 pip install

# 可能需要配置环境变量
export FIGMA_API_TOKEN=your_token

# 启动服务器（具体命令取决于实现）
# 例如：node server.js 或 python server.py
```

## 📚 参考资源

- **Cursor MCP 文档**：查看 Cursor 官方文档关于 MCP 的说明
- **Figma MCP 文档**：查看 Figma MCP 插件的文档
- **项目文档**：检查项目的 README 或其他文档

## ⚠️ 临时解决方案

如果无法启动 Figma MCP 服务器，您可以使用替代方案：

1. **直接从 Figma 导出图片**
   - 打开 Figma 设计文件
   - 导出图片到 `public/images/` 目录

2. **使用占位符图片**（临时）
   - 创建简单的占位符图片
   - 后续再替换为实际图片

3. **从其他地方获取图片**
   - 如果之前下载过这些图片
   - 可以从备份或其他位置复制

## 🔍 需要更多帮助？

如果仍然无法启动服务器，请提供以下信息：

1. Cursor 版本
2. MCP 配置截图（如果有）
3. Cursor 的错误日志
4. 是否有 Figma API Token

这样我可以提供更具体的帮助。
