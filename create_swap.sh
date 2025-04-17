#!/bin/bash

# URL của chính script này để hướng dẫn người dùng
SCRIPT_URL="https://raw.githubusercontent.com/BaoChinh07/swap-script/master/create_swap.sh"

# Nếu truyền đối số là --remove thì xoá swap
if [ "$1" == "--remove" ]; then

  # Nếu file swap tồn tại thì xử lý
  if [ -f /swapfile ]; then
    echo "🧹 Đang xoá swap file..."
    # Tắt swap nếu đang bật
    if swapon --show | grep -q '/swapfile'; then
      swapoff /swapfile
      echo "✅ Đã tắt swap"
    fi

    # Xoá file
    rm -f /swapfile
    echo "✅ Đã xoá file swap"
  else
    echo "ℹ️ Swap chưa được kích hoạt hoặc không tồn tại"
  fi

  # Xoá dòng trong /etc/fstab nếu có
  if grep -q '/swapfile' /etc/fstab; then
    sed -i '/\/swapfile/d' /etc/fstab
    echo "✅ Đã xoá dòng /swapfile khỏi /etc/fstab"
  fi

  exit 0
fi

# Nếu không truyền đối số dung lượng
SIZE_MB=$1
if [ -z "$SIZE_MB" ]; then
  echo "❌ Vui lòng truyền dung lượng swap (MB). Ví dụ: 2048"
  echo "👉 Tạo swap: bash <(curl -s $SCRIPT_URL) 2048"
  echo "👉 Xoá swap:  bash <(curl -s $SCRIPT_URL) --remove"
  exit 1
fi

# Kiểm tra tham số có phải số nguyên không
if ! [[ "$SIZE_MB" =~ ^[0-9]+$ ]]; then
  echo "❌ Dung lượng swap phải là một số nguyên (MB). Ví dụ: 2048"
  echo "👉 Tạo swap: bash <(curl -s $SCRIPT_URL) 2048"
  echo "👉 Xoá swap:  bash <(curl -s $SCRIPT_URL) --remove"
  exit 1
fi

echo "🛠️ Đang tạo swap file với dung lượng ${SIZE_MB}MB..."

# Tạo swap file
fallocate -l "${SIZE_MB}M" /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=$SIZE_MB
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Ghi vào /etc/fstab nếu chưa có
if ! grep -q '/swapfile' /etc/fstab; then
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

echo "✅ Swap đã được tạo:"
swapon --show

