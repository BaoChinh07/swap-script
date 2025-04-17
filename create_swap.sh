#!/bin/bash

SIZE_MB=$1

if [ -z "$SIZE_MB" ]; then
  echo "❌ Vui lòng truyền dung lượng swap (MB). Ví dụ: 2048"
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

