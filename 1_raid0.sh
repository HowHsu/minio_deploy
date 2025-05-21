#!/bin/bash
set -e

# === 参数设置 ===
RAID_DEVICE="/dev/md0"
MOUNT_POINT="/mnt/minio-data"
FILESYSTEM_TYPE="ext4"
DISKS=("/dev/nvme0n1" "/dev/nvme0n2" "/dev/nvme0n3" "/dev/nvme0n4")  # 修改为你自己的磁盘设备路径

# === 检查 mdadm 是否安装 ===
if ! command -v mdadm &> /dev/null; then
    echo "[INFO] 安装 mdadm..."
    sudo apt update && sudo apt install -y mdadm || sudo yum install -y mdadm
fi

# === 清理磁盘 ===
#echo "[INFO] 清除磁盘签名..."
#for disk in "${DISKS[@]}"; do
#    sudo umount "$disk" || true
#    sudo wipefs -a "$disk"
#done

# === 创建 RAID 0 ===
echo "[INFO] 创建 RAID 0 设备 $RAID_DEVICE..."
sudo mdadm --create --verbose "$RAID_DEVICE" --level=0 --raid-devices=${#DISKS[@]} "${DISKS[@]}"

# === 等待 RAID 初始化 ===
sleep 5

# === 创建文件系统 ===
echo "[INFO] 格式化为 $FILESYSTEM_TYPE..."
sudo mkfs.$FILESYSTEM_TYPE "$RAID_DEVICE"

# === 创建挂载点并挂载 ===
echo "[INFO] 挂载到 $MOUNT_POINT..."
sudo mkdir -p "$MOUNT_POINT"
sudo mount "$RAID_DEVICE" "$MOUNT_POINT"

# === 添加到 fstab 以便开机自动挂载 ===
UUID=$(sudo blkid -s UUID -o value "$RAID_DEVICE")
echo "UUID=$UUID $MOUNT_POINT $FILESYSTEM_TYPE defaults,nofail,discard 0 0" | sudo tee -a /etc/fstab

# === 保存 RAID 配置 ===
echo "[INFO] 保存 RAID 配置..."
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf > /dev/null
sudo update-initramfs -u || echo "[WARN] 非 Debian 系统，无需更新 initramfs"

# === 显示 RAID 状态 ===
echo
echo "[SUCCESS] RAID 0 创建完成。状态如下："
cat /proc/mdstat
sudo mdadm --detail "$RAID_DEVICE"

