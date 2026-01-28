#!/bin/bash

# 1. 自动定位内核配置文件 (24.10 通常使用 6.6 或更高级内核)
KCONFIG=$(find target/linux/x86/config-* -maxdepth 0 | head -n 1)
echo "正在注入 eBPF 特性到 24.10 内核配置: $KCONFIG"

# 2. 强制开启 Kprobes 和事件追踪
sed -i '/CONFIG_KPROBES/d' "$KCONFIG"
echo 'CONFIG_KPROBES=y' >> "$KCONFIG"
echo 'CONFIG_KPROBE_EVENTS=y' >> "$KCONFIG"
echo 'CONFIG_BPF_EVENTS=y' >> "$KCONFIG"

# 3. 开启 BTF (24.10 运行现代化 BPF 程序的基石)
sed -i '/CONFIG_DEBUG_INFO_BTF/d' "$KCONFIG"
echo 'CONFIG_DEBUG_INFO_BTF=y' >> "$KCONFIG"
echo 'CONFIG_DEBUG_INFO_BTF_MODULES=y' >> "$KCONFIG"

# 4. 开启 BPF 进阶支持
echo 'CONFIG_BPF_SYSCALL=y' >> "$KCONFIG"
echo 'CONFIG_BPF_JIT=y' >> "$KCONFIG"
echo 'CONFIG_BPF_JIT_ALWAYS_ON=y' >> "$KCONFIG"
echo 'CONFIG_HAVE_EBPF_JIT=y' >> "$KCONFIG"

# 5. 开启 DWARF 调试信息（BTF 生成的先决条件）
echo 'CONFIG_DEBUG_INFO=y' >> "$KCONFIG"
echo 'CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y' >> "$KCONFIG"

# 6. 扩容内核分区 (针对 J4125 建议扩至 64MB)
sed -i 's/CONFIG_TARGET_KERNEL_PARTSIZE=16/CONFIG_TARGET_KERNEL_PARTSIZE=64/' .config
