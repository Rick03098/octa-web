#!/bin/bash
# 图片下载脚本 - 从 localhost:3845 下载所有必需的图片

# 切换到脚本所在目录
cd "$(dirname "$0")"

# 图片服务器地址
BASE_URL="http://localhost:3845/assets"

# 必需的图片列表
IMAGES=(
  "e503f988099e962c10dd595d7fb80340d7487ce9.png"
  "b4eb843683aafc4dd42a29a982a4295167ad755a.png"
  "708-17842.png"
  "8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png"
)

echo "========================================="
echo "图片下载脚本"
echo "========================================="
echo ""

# 检查服务器是否可访问
echo "检查 localhost:3845 服务器..."
if curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/test" > /dev/null 2>&1; then
  echo "✅ 服务器连接正常"
else
  echo "❌ 无法连接到 localhost:3845"
  echo ""
  echo "请确保："
  echo "1. Figma MCP 服务器正在运行"
  echo "2. 服务器运行在 localhost:3845"
  echo ""
  read -p "是否仍然尝试下载？(y/n) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "下载已取消"
    exit 1
  fi
fi

echo ""
echo "开始下载图片..."
echo ""

# 下载计数器
SUCCESS=0
FAILED=0

# 循环下载每个图片
for img in "${IMAGES[@]}"; do
  echo -n "下载 $img ... "
  
  if curl -f -s -o "$img" "$BASE_URL/$img"; then
    # 检查文件大小
    if [ -f "$img" ] && [ -s "$img" ]; then
      size=$(ls -lh "$img" | awk '{print $5}')
      echo "✅ 成功 ($size)"
      ((SUCCESS++))
    else
      echo "❌ 失败 (文件为空)"
      rm -f "$img"
      ((FAILED++))
    fi
  else
    echo "❌ 失败 (无法下载)"
    rm -f "$img"
    ((FAILED++))
  fi
done

echo ""
echo "========================================="
echo "下载完成"
echo "========================================="
echo "✅ 成功: $SUCCESS"
echo "❌ 失败: $FAILED"
echo ""

if [ $SUCCESS -gt 0 ]; then
  echo "已下载的图片："
  ls -lh *.png 2>/dev/null | awk '{print "  - " $9 " (" $5 ")"}'
fi

echo ""
