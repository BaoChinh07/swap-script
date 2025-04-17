#!/bin/bash

if [ -z "$1" ]; then
    echo "❌ Vui lòng truyền vào dung lượng swap (MB). Ví dụ: 2048"
    exit 1
fi

SWAP_SIZE_MB=$1
SWAP_FILE="/swapfile"

echo "🛠️ Đang tạo swap file với dung lượng ${SWAP_SIZE_MB}MB..."

sudo fallocate -l ${SWAP_SIZE_MB}M $SWAP_FILE

if [ $? -ne 0 ]; then
    echo "⚠️ fallocate thất bại, thử lại với dd..."
    sudo dd if=/dev/zero of=$SWAP_FILE bs=1M count=$SWAP_SIZE_MB
fi

sudo chmod 600 $SWAP_FILE
sudo mkswap $SWAP_FILE
sudo swapon $SWAP_FILE

if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
fi

echo "✅ Swap đã được tạo:"
swapon --show
