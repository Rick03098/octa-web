# 必需的图片资源清单

## 重要提示

本项目现在使用 `public/images/` 目录存放图片资源，不再依赖 `localhost:3845` 的 Figma MCP 服务器。

## 必需的图片文件

请将以下图片文件放入 `public/images/` 目录：

1. **e503f988099e962c10dd595d7fb80340d7487ce9.png**
   - 用途：聊天背景图、主界面环境卡片、报告页面
   - 使用位置：
     - `src/features/Chat/ChatView.tsx`
     - `src/features/ChatIntro/ChatIntroView.tsx`
     - `src/features/MainDashboard/MainDashboardView.tsx`
     - `src/features/Report/ReportView.tsx`

2. **b4eb843683aafc4dd42a29a982a4295167ad755a.png**
   - 用途：拍摄教程插图
   - 使用位置：
     - `src/features/Tutorial/TutorialView.tsx`

3. **708-17842.png**
   - 用途：报告预览页面背景渐变图
   - 使用位置：
     - `src/features/Preview/PreviewView.tsx`

4. **8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png**
   - 用途：拍摄页面占位图
   - 使用位置：
     - `src/features/Capture/CaptureView.tsx`

## 目录结构

```
octa-web/
└── public/
    └── images/
        ├── e503f988099e962c10dd595d7fb80340d7487ce9.png
        ├── b4eb843683aafc4dd42a29a982a4295167ad755a.png
        ├── 708-17842.png
        └── 8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png
```

## 获取图片的方式

### 方式 1：从 Figma MCP 服务器下载（如果有访问权限）

1. 启动 Figma MCP 服务器（`localhost:3845`）
2. 访问图片 URL：
   - `http://localhost:3845/assets/e503f988099e962c10dd595d7fb80340d7487ce9.png`
   - `http://localhost:3845/assets/b4eb843683aafc4dd42a29a982a4295167ad755a.png`
   - `http://localhost:3845/assets/708-17842.png`
   - `http://localhost:3845/assets/8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png`
3. 保存到 `public/images/` 目录

### 方式 2：从 Figma 设计文件导出

1. 打开对应的 Figma 设计文件
2. 找到对应的图片元素
3. 导出为 PNG 格式
4. 重命名为上述文件名
5. 保存到 `public/images/` 目录

### 方式 3：使用占位符图片（临时方案）

如果暂时无法获取原始图片，可以：
1. 创建简单的占位符图片（纯色或渐变背景）
2. 使用相同的文件名保存到 `public/images/` 目录
3. 后续再替换为实际图片

## 验证

运行以下命令检查图片文件是否存在：

```bash
# 检查所有必需的图片文件
ls -la public/images/

# 或者使用 find 命令
find public/images -name "*.png" | sort
```

应该看到 4 个 PNG 文件。

## Git 跟踪

确保 `public/images/` 目录中的图片文件被 Git 跟踪：

```bash
# 检查 .gitignore 是否忽略了图片文件
grep -i "images\|\.png" .gitignore

# 如果被忽略，需要取消忽略（或确保图片目录不被忽略）
```

**注意**：`public/images/` 目录应该被 Git 跟踪，以便代码和图片资源一起分发。

## 构建验证

运行构建命令后，检查 `dist/images/` 目录是否包含所有图片：

```bash
npm run build
ls -la dist/images/
```

所有图片应该出现在 `dist/images/` 目录中。

## 注意事项

- 图片文件名必须完全匹配（区分大小写）
- 图片文件路径已改为相对路径 `/images/xxx.png`，无需修改代码
- 如果图片缺失，页面会显示 `onError` 回调的处理（通常是隐藏图片）
- 建议使用压缩后的图片文件以减小项目体积
