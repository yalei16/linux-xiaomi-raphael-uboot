#!/bin/bash

# 系统配置函数
# 根据系统类型和桌面环境返回配置变量

system_config() {
    local SYSTEM_TYPE="$1"
    local DESKTOP_ENV="$2"

    case "$SYSTEM_TYPE" in
        debian-server)
            echo "IMAGE_SIZE=3G"
            echo "IS_DESKTOP=false"
            echo "EXTRA_PACKAGES="
            ;;
        debian-gnome)
            echo "IMAGE_SIZE=6G"
            echo "IS_DESKTOP=true"
            echo "EXTRA_PACKAGES=gnome-core,gnome-shell,gnome-terminal,gnome-control-center,gdm3,nautilus"
            ;;
        debian-phosh)
            echo "IMAGE_SIZE=5G"
            echo "IS_DESKTOP=true"
            echo "EXTRA_PACKAGES=phosh,phosh-tablet,squeekboard"
            ;;
        ubuntu-server)
            echo "IMAGE_SIZE=3G"
            echo "IS_DESKTOP=false"
            echo "EXTRA_PACKAGES="
            ;;
        ubuntu-gnome)
            echo "IMAGE_SIZE=6G"
            echo "IS_DESKTOP=true"
            echo "EXTRA_PACKAGES=gnome-core,gnome-shell,gnome-terminal,gnome-control-center,gdm3,nautilus"
            ;;
        ubuntu-phosh)
            echo "IMAGE_SIZE=5G"
            echo "IS_DESKTOP=true"
            echo "EXTRA_PACKAGES=phosh,phosh-tablet,squeekboard"
            ;;
        kali-gnome)
            echo "IMAGE_SIZE=8G"
            echo "IS_DESKTOP=true"
            # Kali GNOME 桌面版：核心安全工具 + GNOME 桌面 + onboard 虚拟键盘
            echo "EXTRA_PACKAGES=kali-linux-core,kali-desktop-gnome,onboard,onboard-data"
            ;;
        kali-server)
            echo "IMAGE_SIZE=5G"
            echo "IS_DESKTOP=false"
            echo "EXTRA_PACKAGES=kali-linux-core,kali-linux-headless"
            ;;
        *)
            echo "错误: 不支持的系统类型: $SYSTEM_TYPE" >&2
            exit 1
            ;;
    esac
}
