#!/bin/bash

# 镜像源配置函数
# 根据系统类型返回镜像源配置变量

sources_config() {
    local SYSTEM_TYPE="$1"

    case "$SYSTEM_TYPE" in
        debian-*)
            local SUITE="${DEBIAN_VERSION:-trixie}"
            echo "MIRROR=https://mirrors.tuna.tsinghua.edu.cn/debian"
            echo "SUITE=$SUITE"
            echo "COMPONENTS=main,contrib,non-free,non-free-firmware"
            echo "KEYRING_ARG="
            ;;
        ubuntu-*)
            local SUITE="${UBUNTU_VERSION:-resolute}"
            echo "MIRROR=https://mirrors.tuna.tsinghua.edu.cn/ubuntu"
            echo "SUITE=$SUITE"
            echo "COMPONENTS=main,restricted,universe,multiverse"
            echo "KEYRING_ARG="
            ;;
        kali-*)
            local SUITE="${KALI_VERSION:-kali-rolling}"
            # 使用国内镜像加速
            echo "MIRROR=https://mirrors.ustc.edu.cn/kali"
            echo "SUITE=$SUITE"
            echo "COMPONENTS=main,contrib,non-free,non-free-firmware"
            # Kali 需要指定 keyring
            if [ -f /usr/share/keyrings/kali-archive-keyring.gpg ]; then
                echo "KEYRING_ARG=--keyring=/usr/share/keyrings/kali-archive-keyring.gpg"
            else
                echo "KEYRING_ARG="
            fi
            ;;
        *)
            echo "错误: 不支持的系统类型: $SYSTEM_TYPE" >&2
            exit 1
            ;;
    esac
}
