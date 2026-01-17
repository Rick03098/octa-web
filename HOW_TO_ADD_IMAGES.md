# 如何将图片文件存放到 public/images/ 目录

## 步骤 1：确认目录已创建

`public/images/` 目录已经创建好了，路径是：
```
octa-web/public/images/
```

## 步骤 2：获取图片文件

您有以下几种方式获取图片：

### 方式 1：从 localhost:3845 下载（如果 Figma MCP 服务器正在运行）

如果您当前有 Figma MCP 服务器运行在 `localhost:3845`，可以使用以下命令下载图片：

```bash
cd /Users/wangjianle/OCTA/Code/OCTA/octa-web/public/images

# 下载图片 1：聊天背景图
curl -o e503f988099e962c10dd595d7fb80340d7487ce9.png "http://localhost:3845/assets/e503f988099e962c10dd595d7fb80340d7487ce9.png"

# 下载图片 2：教程插图
curl -o b4eb843683aafc4dd42a29a982a4295167ad755a.png "http://localhost:3845/assets/b4eb843683aafc4dd42a29a982a4295167ad755a.png"

# 下载图片 3：预览图
curl -o 708-17842.png "http://localhost:3845/assets/708-17842.png"

# 下载图片 4：拍摄图
curl -o 8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png "http://localhost:3845/assets/8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png"
```

### 方式 2：从浏览器下载

1. 确保 Figma MCP 服务器运行在 `localhost:3845`
2. 在浏览器中打开以下 URL：
   - http://localhost:3845/assets/e503f988099e962c10dd595d7fb80340d7487ce9.png
   - http://localhost:3845/assets/b4eb843683aafc4dd42a29a982a4295167ad755a.png
   - http://localhost:3845/assets/708-17842.png
   - http://localhost:3845/assets/8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png
3. 右键点击图片 → "另存为" → 保存到 `public/images/` 目录
4. 确保文件名完全匹配（区分大小写）

### 方式 3：从 Figma 设计文件导出

1. 打开对应的 Figma 设计文件
2. 找到对应的图片元素/图层
3. 选择图片元素
4. 在右侧面板点击 "Export"（导出）
5. 选择 PNG 格式
6. 导出并重命名为对应的文件名
7. 将文件移动到 `public/images/` 目录

### 方式 4：手动拖拽（如果有图片文件）

1. 打开 Finder（文件管理器）
2. 找到您的图片文件所在位置
3. 打开终端，定位到项目目录：
   ```bash
   cd /Users/wangjianle/OCTA/Code/OCTA/octa-web/public/images
   ```
4. 或者直接使用 Finder：
   - 打开 `octa-web/public/images/` 文件夹
   - 将图片文件拖拽进去
5. 确保文件名完全匹配

## 步骤 3：验证图片文件

下载/复制完成后，运行以下命令验证：

```bash
cd /Users/wangjianle/OCTA/Code/OCTA/octa-web

# 列出所有图片文件
ls -lh public/images/*.png

# 或者检查文件大小（应该都有内容，不是 0 字节）
ls -lh public/images/
```

应该看到 4 个 PNG 文件：
- `e503f988099e962c10dd595d7fb80340d7487ce9.png`
- `b4eb843683aafc4dd42a29a982a4295167ad755a.png`
- `708-17842.png`
- `8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png`

## 步骤 4：测试图片加载

1. 启动开发服务器：
   ```bash
   cd /Users/wangjianle/OCTA/Code/OCTA/octa-web
   npm run dev
   ```

2. 在浏览器中访问项目，检查图片是否正常显示

3. 或者构建生产版本测试：
   ```bash
   npm run build
   ls -lh dist/images/  # 应该看到所有图片文件
   ```

## 注意事项

1. **文件名必须完全匹配**（区分大小写）
   - ✅ `e503f988099e962c10dd595d7fb80340d7487ce9.png`
   - ❌ `E503F988099E962C10DD595D7FB80340D7487CE9.PNG`

2. **确保文件扩展名正确**
   - 必须是 `.png` 格式

3. **Git 跟踪**
   - `public/images/` 目录不会被 `.gitignore` 忽略
   - 图片文件会被 Git 跟踪（确保提交到仓库）

4. **文件路径**
   - 图片路径在代码中已改为 `/images/xxx.png`
   - 不需要修改代码，只需要将文件放入 `public/images/` 目录

## 快速验证脚本

运行以下命令一次性检查所有图片是否存在：

```bash
cd /Users/wangjianle/OCTA/Code/OCTA/octa-web/public/images

for img in \
  "e503f988099e962c10dd595d7fb80340d7487ce9.png" \
  "b4eb843683aafc4dd42a29a982a4295167ad755a.png" \
  "708-17842.png" \
  "8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png"; do
  if [ -f "$img" ]; then
    echo "✅ $img - 已存在"
  else
    echo "❌ $img - 缺失"
  fi
done
```

## 需要帮助？

如果遇到问题：
1. 检查 `public/images/` 目录是否存在
2. 检查文件名是否正确（区分大小写）
3. 检查文件权限（应该可读）
4. 查看浏览器控制台的错误信息
