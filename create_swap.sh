#!/bin/bash

# Lưu URL của chính script để gợi ý lại
SCRIPT_URL="https://raw.githubusercontent.com/BaoChinh07/swap-script/master/create_swap.sh"

SIZE_MB=$1

if [ -z "$SIZE_MB" ]; then
  echo "❌ Vui lòng truyền dung lượng swap (MB). Ví dụ: 2048"
  echo "👉 Ví dụ: bash <(curl -s $SCRIPT_URL) 2048"
  exit 1
else

if ! [[ "$SIZE_MB" =~ ^[0-9]+$ ]]; then
  echo "❌ Dung lượng swap phải là một số nguyên (MB). Ví dụ: 2048"
  echo "👉 Ví dụ: bash <(curl -s $SCRIPT_URL) 2048"
  exit 1
fi


echo "🛠️ Đang tạo swap file với dung lượng ${SIZE_MB}MB..."

fallocate -l "${SIZE_MB}M" /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=$SIZE_MB
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab > /dev/null

echo "✅ Swap đã được tạo:"
swapon --show

