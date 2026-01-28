#!/bin/bash

# 1. 自动定位内核配置文件模板
KCONFIG=$(find target/linux/x86 -name "config-*" | head -n 1)

# 2. 【核心修复】清理并注入内核级开关
# 必须先删除旧的冲突项，确保 REDUCED 为 n，BTF 为 y
sed -i '/CONFIG_DEBUG_INFO/d' "$KCONFIG"
sed -i '/CONFIG_DEBUG_INFO_REDUCED/d' "$KCONFIG"
sed -i '/CONFIG_DEBUG_INFO_BTF/d' "$KCONFIG"
sed -i '/CONFIG_KPROBES/d' "$KCONFIG"

{
    echo 'CONFIG_DEBUG_KERNEL=y'
    echo 'CONFIG_DEBUG_INFO=y'
    echo 'CONFIG_DEBUG_INFO_BTF=y'
    echo 'CONFIG_DEBUG_INFO_BTF_MODULES=y'
    echo 'CONFIG_DEBUG_INFO_REDUCED=n'
    echo 'CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y'
    echo 'CONFIG_KPROBES=y'
    echo 'CONFIG_KPROBE_EVENTS=y'
    echo 'CONFIG_BPF_EVENTS=y'
    echo 'CONFIG_IKCONFIG=y'
    echo 'CONFIG_IKCONFIG_PROC=y'
} >> "$KCONFIG"

# 3. 其它基础修改 (IP 和 irqbalance 保持之前成功的逻辑)
sed -i 's/192.168.1.1/192.168.1.100/g' package/base-files/files/bin/config_generate
mkdir -p package/base-files/files/etc/uci-defaults
echo "service irqbalance enable && service irqbalance start" > package/base-files/files/etc/uci-defaults/99-custom-settings
