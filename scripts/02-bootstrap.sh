#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] 📦 开始构建基础系统..."

# 检查 rootdir 是否存在
if [ -d "rootdir" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 🧹 清理旧的 rootdir..."
    sudo rm -rf rootdir
fi

mkdir -p rootdir

BOOTSTRAP_TOOL="${BOOTSTRAP_TOOL:-mmdebstrap}"

if [ "$BOOTSTRAP_TOOL" = "mmdebstrap" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 使用 mmdebstrap 构建..."
    echo "[$(date +'%Y-%m-%d %H:%M:%S')]   Suite: $SUITE"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')]   Mirror: $MIRROR"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')]   Components: $COMPONENTS"

    # 基础包列表
    BASE_PACKAGES="openssh-server,sudo,net-tools,iputils-ping,dnsutils,curl,wget,htop,vim,nano,usbutils,pciutils,i2c-tools,parted,gdisk,f2fs-tools,e2fsprogs,dosfstools,wireless-tools,wpasupplicant,iw,rfkill,bluez,bluetooth,libpam-systemd,systemd-timesyncd,dbus,polkitd,locales,console-setup,keyboard-configuration,firmware-linux-free,firmware-misc-nonfree,firmware-realtek,firmware-atheros,firmware-brcm80211,firmware-libertas,firmware-ti-connectivity,firmware-zd1211,linux-firmware,mesa-vulkan-drivers,libglx-mesa0,libgl1-mesa-dri,libglx0,libegl1,libgles2,mesa-utils,wayland-protocols,libwayland-client0,libwayland-server0,libwayland-cursor0,libwayland-egl1,libwayland-bin,xwayland,pulseaudio,pulseaudio-utils,alsa-utils,libpam-fprintd,fprintd"

    # 添加额外包
    if [ -n "$EXTRA_PACKAGES" ]; then
        PACKAGES="$BASE_PACKAGES,$EXTRA_PACKAGES"
    else
        PACKAGES="$BASE_PACKAGES"
    fi

    echo "[$(date +'%Y-%m-%d %H:%M:%S')]   安装包数量: $(echo "$PACKAGES" | tr ',' '\n' | wc -l)"

    # 构建 mmdebstrap 参数
    MM_ARGS="--variant=standard --components=$COMPONENTS"

    # 如果有 keyring 参数则添加
    if [ -n "$KEYRING_ARG" ]; then
        MM_ARGS="$MM_ARGS $KEYRING_ARG"
        echo "[$(date +'%Y-%m-%d %H:%M:%S')]   使用自定义 keyring"
    fi

    # Kali 可能需要跳过 Valid-Until 检查
    if [[ "$SYSTEM_TYPE" == kali-* ]]; then
        MM_ARGS="$MM_ARGS --aptopt=Acquire::Check-Valid-Until=false"
    fi

    sudo mmdebstrap \
        $MM_ARGS \
        --include="$PACKAGES" \
        "$SUITE" \
        rootdir/ \
        "$MIRROR"

else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 使用 debootstrap 构建..."

    DEB_ARGS="--components=$COMPONENTS"

    if [ -n "$KEYRING_ARG" ]; then
        # debootstrap 的 keyring 参数格式不同
        KEYRING_FILE=$(echo "$KEYRING_ARG" | sed 's/--keyring=//')
        DEB_ARGS="$DEB_ARGS --keyring=$KEYRING_FILE"
    fi

    sudo debootstrap \
        $DEB_ARGS \
        "$SUITE" \
        rootdir/ \
        "$MIRROR"
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ 基础系统构建完成"
