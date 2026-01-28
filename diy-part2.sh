#!/bin/bash

# 1. 自动定位内核配置文件
KCONFIG=$(find target/linux/x86/config-* -maxdepth 0 | head -n 1)
echo "正在注入 eBPF 特性到 24.10 内核配置: $KCONFIG"

# 2. 注入 eBPF/BTF 必要内核开关 (使用追加模式)
{
    echo 'CONFIG_KPROBES=y'
    echo 'CONFIG_KPROBE_EVENTS=y'
    echo 'CONFIG_BPF_EVENTS=y'
    echo 'CONFIG_DEBUG_INFO_BTF=y'
    echo 'CONFIG_DEBUG_INFO_BTF_MODULES=y'
    echo 'CONFIG_BPF_SYSCALL=y'
    echo 'CONFIG_BPF_JIT=y'
    echo 'CONFIG_BPF_JIT_ALWAYS_ON=y'
    echo 'CONFIG_DEBUG_INFO=y'
    echo 'CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y'
} >> "$KCONFIG"

# 3. 扩容分区 (BTF 会显著增大内核体积，必须扩容)
# 将内核分区从默认的 16MB 扩容至 64MB
sed -i 's/CONFIG_TARGET_KERNEL_PARTSIZE=16/CONFIG_TARGET_KERNEL_PARTSIZE=64/' .config
# 将根文件系统分区扩容至 512MB (方便以后折腾)
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=104/CONFIG_TARGET_ROOTFS_PARTSIZE=512/' .config

# 4. 确保 irqbalance 服务默认启动
echo "service irqbalance start" >> package/base-files/files/etc/rc.local

# 5. 强力清理无线组件 (防止 feeds 自动补全)
sed -i '/wpad/d' .config
sed -i '/hostapd/d' .config
sed -i '/iwinfo/d' .config
