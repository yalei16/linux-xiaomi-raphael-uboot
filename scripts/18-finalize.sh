#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] 🔧 最终处理..."

# 同步文件系统
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   同步文件系统..."
sync

# 卸载挂载点
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   卸载挂载点..."
if mountpoint -q rootdir/dev; then
    sudo umount -l rootdir/dev || true
fi
if mountpoint -q rootdir/proc; then
    sudo umount -l rootdir/proc || true
fi
if mountpoint -q rootdir/sys; then
    sudo umount -l rootdir/sys || true
fi

# 卸载 rootdir 本身
if mountpoint -q rootdir; then
    sudo umount -l rootdir || true
fi

# 等待卸载完成
sleep 2

# 检查 loop 设备并清理
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   清理 loop 设备..."
for loopdev in $(losetup -a | grep rootfs.img | cut -d: -f1); do
    echo "[$(date +'%Y-%m-%d %H:%M:%S')]     断开 $loopdev"
    sudo losetup -d "$loopdev" || true
done

# 打包为 tar.gz 格式
echo "[$(date +'%Y-%m-%d %H:%M:%S')] 📦 打包 rootfs 为 tar.gz..."

# 重新挂载 rootfs.img 到临时目录进行打包
MOUNT_DIR=$(mktemp -d)
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   临时挂载目录: $MOUNT_DIR"

sudo mount -o loop rootfs.img "$MOUNT_DIR"

# 打包为 tar.gz
echo "[$(date +'%Y-%m-%d %H:%M:%S')]   正在打包 rootfs.tar.gz (这可能需要几分钟)..."
sudo tar -czpf rootfs.tar.gz -C "$MOUNT_DIR" .

# 卸载临时目录
sudo umount "$MOUNT_DIR"
rmdir "$MOUNT_DIR"

# 设置权限
sudo chown $(id -u):$(id -g) rootfs.tar.gz

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ tar.gz 打包完成"

# 显示文件信息
echo "[$(date +'%Y-%m-%d %H:%M:%S')] 📊 产物信息:"
ls -lh rootfs.tar.gz

# 可选：同时保留 rootfs.img（如果需要）
# 如果不需要 rootfs.img，可以删除以节省空间
# rm -f rootfs.img

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ 最终处理完成"
