#!/bin/bash

SCRIPT_URL="https://raw.githubusercontent.com/BaoChinh07/swap-script/master/create_swap.sh"
SWAP_FILE="/swapfile"

# Nếu tham số là --remove hoặc remove thì thực hiện xoá swap
if [[ "$1" == "--remove" || "$1" == "remove" ]]; then
  echo "🧹 Đang xoá swap file..."

  if swapon --show | grep -q "$SWAP_FILE"; then
    swapoff $SWAP_FILE
    echo "✅ Đã tắt swap"
  else
    echo "ℹ️ Swap chưa được kích hoạt hoặc không tồn tại"
  fi

  if [ -f "$SWAP_FILE" ]; then
    rm -f $SWAP_FILE
    echo "✅ Đã xoá file swap"
  fi

  # Xoá dòng trong /etc/fstab nếu tồn tại
  if grep -q '/swapfile' /etc/fstab; then
    sed -i '/\/swapfile/d' /etc/fstab
    echo "✅ Đã xoá dòng /swapfile khỏi /etc/fstab"
  fi
fi

# Nếu không phải là --remove thì kiểm tra tham số tạo swap
SIZE_MB=$1

if [ -z "$SIZE_MB" ]; then
  echo "❌ Vui lòng truyền dung lượng swap (MB). Ví dụ: 2048"
  echo "👉 Tạo swap: bash <(curl -s $SCRIPT_URL) 2048"
  echo "👉 Xoá swap:  bash <(curl -s $SCRIPT_URL) --remove"
  exit 1
fi

if ! [[ "$SIZE_MB" =~ ^[0-9]+$ ]]; then
  echo "❌ Dung lượng swap phải là một số nguyên (MB). Ví dụ: 2048"
  echo "👉 Tạo swap: bash <(curl -s $SCRIPT_URL) 2048"
  echo "👉 Xoá swap:  bash <(curl -s $SCRIPT_URL) --remove"
  exit 1
fi

echo "🛠️ Đang tạo swap file với dung lượng ${SIZE_MB}MB..."

fallocate -l "${SIZE_MB}M" $SWAP_FILE || dd if=/dev/zero of=$SWAP_FILE bs=1M count=$SIZE_MB
chmod 600 $SWAP_FILE
mkswap $SWAP_FILE
swapon $SWAP_FILE

echo "$SWAP_FILE none swap sw 0 0" | tee -a /etc/fstab > /dev/null

echo "✅ Swap đã được tạo:"
swapon --show
