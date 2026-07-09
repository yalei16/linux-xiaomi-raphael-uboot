#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] 📋 配置 apt 软件源..."

# 根据发行版配置不同的源
if [[ "$SYSTEM_TYPE" == debian-* ]]; then
    cat > rootdir/etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/debian $SUITE main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian $SUITE-updates main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security $SUITE-security main contrib non-free non-free-firmware
EOF
    echo "[$(date +'%Y-%m-%d %H:%M:%S')]   Debian 源已配置"

elif [[ "$SYSTEM_TYPE" == ubuntu-* ]]; then
    cat > rootdir/etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu $SUITE main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu $SUITE-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu $SUITE-security main restricted universe multiverse
EOF
    echo "[$(date +'%Y-%m-%d %H:%M:%S')]   Ubuntu 源已配置"

elif [[ "$SYSTEM_TYPE" == kali-* ]]; then
    # Kali 使用官方源或国内镜像
    cat > rootdir/etc/apt/sources.list <<EOF
deb https://mirrors.ustc.edu.cn/kali kali-rolling main contrib non-free non-free-firmware
# deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
EOF

    # Kali 需要禁用 Valid-Until 检查（滚动发行版）
    cat > rootdir/etc/apt/apt.conf.d/99kali <<EOF
Acquire::Check-Valid-Until "false";
Acquire::AllowInsecureRepositories "false";
EOF

    echo "[$(date +'%Y-%m-%d %H:%M:%S')]   Kali 源已配置"
fi

# 配置 apt 偏好
mkdir -p rootdir/etc/apt/apt.conf.d
cat > rootdir/etc/apt/apt.conf.d/99custom <<EOF
APT::Install-Recommends "false";
APT::Install-Suggests "false";
APT::Get::Assume-Yes "true";
APT::Get::AllowUnauthenticated "false";
DPkg::Options {"--force-confdef";"--force-confold"};
EOF

# 更新 apt 缓存
chroot rootdir apt-get update

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ apt 配置完成"
