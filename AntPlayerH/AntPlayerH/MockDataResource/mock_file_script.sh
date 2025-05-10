#!/bin/bash

# 定义 mock_routes.json 文件路径
MOCK_ROUTES_FILE="mock_routes.json"

# 定义输出目录
OUTPUT_DIR="."

# 检查 mock_routes.json 是否存在
if [ ! -f "$MOCK_ROUTES_FILE" ]; then
  echo "Error: $MOCK_ROUTES_FILE not found!"
  exit 1
fi

# 读取 mock_routes.json 中的 value 值并创建对应的 JSON 文件
jq -r 'to_entries[] | .value' "$MOCK_ROUTES_FILE" | while read -r filename; do
  # 定义文件路径
  filepath="$OUTPUT_DIR/$filename.json"

  # 检查文件是否已存在
  if [ -f "$filepath" ]; then
    echo "File $filepath already exists. Skipping..."
    continue
  fi

  # 创建 JSON 文件
  cat > "$filepath" <<EOF
{
  "status": 200,
  "message": "Mock data for $filename"
}
EOF

  echo "Created $filepath"
done