#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] 📦 安装额外软件包..."

# 更新 apt
chroot rootdir apt-get update

# 安装桌面环境相关包（如果 IS_DESKTOP=true）
if [ "$IS_DESKTOP" = "true" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 🎨 安装桌面环境包..."

    case "$SYSTEM_TYPE" in
        *-gnome)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')]   安装 GNOME 相关包..."
            chroot rootdir apt-get install -y \
                gnome-session \
                gnome-shell-extensions \
                gnome-tweaks \
                gnome-icon-theme \
                gnome-themes-extra \
                adwaita-icon-theme \
                mutter \
                gsettings-desktop-schemas \
                gdm3

            # 安装 onboard 虚拟键盘（Ubuntu 的虚拟键盘，支持 GNOME）
            echo "[$(date +'%Y-%m-%d %H:%M:%S')]   安装 onboard 虚拟键盘..."
            chroot rootdir apt-get install -y onboard onboard-data || true

            # 安装 caribou 作为备选（GNOME 原生虚拟键盘）
            chroot rootdir apt-get install -y caribou || true

            # 配置 GNOME 自动弹出虚拟键盘
            echo "[$(date +'%Y-%m-%d %H:%M:%S')]   配置 GNOME 自动弹出虚拟键盘..."

            # 创建 GNOME 键盘配置
            mkdir -p rootdir/etc/dconf/db/local.d
            cat > rootdir/etc/dconf/db/local.d/00-keyboard <<'KEYBOARD_EOF'
[org/gnome/desktop/a11y/applications]
screen-keyboard-enabled=true

[org/gnome/desktop/interface]
gtk-im-module='onboard'

[org/onboard]
auto-show=true
show-status-icon=true
layout='Compact'
KEYBOARD_EOF

            # 创建 dconf 配置文件
            mkdir -p rootdir/etc/dconf/profile
            cat > rootdir/etc/dconf/profile/user <<'PROFILE_EOF'
user-db:user
system-db:local
PROFILE_EOF

            # 创建 dconf 数据库更新脚本
            mkdir -p rootdir/etc/dconf/db/local.d/locks

            # 更新 dconf 数据库
            chroot rootdir dconf update || true

            # 配置 GDM 自动弹出键盘
            mkdir -p rootdir/etc/gdm3
            cat > rootdir/etc/gdm3/custom.conf <<'GDM_EOF'
[daemon]
# 启用虚拟键盘
WaylandEnable=true

[security]

[xdmcp]

[chooser]

[debug]
GDM_EOF

            # 创建 systemd 服务，确保 onboard 在 GNOME 会话中自动启动
            cat > rootdir/etc/xdg/autostart/onboard-autostart.desktop <<'AUTOSTART_EOF'
[Desktop Entry]
Type=Application
Name=Onboard Virtual Keyboard
Comment=On-screen keyboard
Exec=/usr/bin/onboard --auto-show
Icon=onboard
Categories=Accessibility;
X-GNOME-Autostart-enabled=true
AUTOSTART_EOF

            # 配置 onboard 自动显示
            mkdir -p rootdir/etc/onboard
            cat > rootdir/etc/onboard/onboard-defaults.conf <<'ONBOARD_EOF'
[main]
auto-show=true
show-status-icon=true

[window]
force-to-top=true

[auto-show]
enabled=true
hide-on-key-press=true
EOF

            echo "[$(date +'%Y-%m-%d %H:%M:%S')]   GNOME 虚拟键盘配置完成"
            ;;

        *-phosh)
            echo "[$(date +'%Y-%m-%d %H:%M:%S')]   安装 Phosh 相关包..."
            chroot rootdir apt-get install -y \
                phosh \
                phosh-tablet \
                squeekboard \
                gnome-session
            ;;
    esac

    # 安装通用桌面工具
    chroot rootdir apt-get install -y \
        firefox-esr \
        network-manager \
        network-manager-gnome \
        modemmanager \
        xdg-utils \
        xdg-user-dirs \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        || true
fi

# 安装 Kali 专用工具（如果是 Kali）
if [[ "$SYSTEM_TYPE" == kali-* ]]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 🐉 安装 Kali 工具包..."

    # 确保 kali-archive-keyring 已安装
    chroot rootdir apt-get install -y kali-archive-keyring || true

    # 更新并安装 Kali 核心工具
    chroot rootdir apt-get update

    # 安装 kali-linux-core（基础安全工具集）
    echo "[$(date +'%Y-%m-%d %H:%M:%S')]   安装 kali-linux-core..."
    chroot rootdir apt-get install -y kali-linux-core || true

    # 如果是桌面版，安装更多工具
    if [ "$IS_DESKTOP" = "true" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')]   安装 Kali 桌面工具..."
        chroot rootdir apt-get install -y \
            kali-desktop-gnome \
            kali-tools-information-gathering \
            kali-tools-vulnerability \
            kali-tools-wireless \
            kali-tools-web \
            kali-tools-forensics \
            kali-tools-reverse-engineering \
            kali-tools-exploitation \
            kali-tools-post-exploitation \
            kali-tools-sniffing-spoofing \
            kali-tools-passwords \
            kali-tools-crypto-stego \
            kali-tools-fuzzing \
            || true
    fi

    echo "[$(date +'%Y-%m-%d %H:%M:%S')]   Kali 工具安装完成"
fi

# 清理
chroot rootdir apt-get clean
chroot rootdir apt-get autoremove -y

echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ 软件包安装完成"
