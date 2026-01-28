#!/bin/bash

# 1. 注入 eBPF/BTF 核心开关到内核模板
# 这一步是为了让 BTF 符号表出现在 /sys/kernel/btf/vmlinux
find target/linux/x86 -name "config-*" | xargs -i sh -c "
    echo 'CONFIG_DEBUG_INFO_BTF=y' >> {}
    echo 'CONFIG_DEBUG_INFO_BTF_MODULES=y' >> {}
    echo 'CONFIG_BPF_EVENTS=y' >> {}
    echo 'CONFIG_KPROBES=y' >> {}
    echo 'CONFIG_KPROBE_EVENTS=y' >> {}
    echo 'CONFIG_BPF_SYSCALL=y' >> {}
    echo 'CONFIG_BPF_JIT=y' >> {}
    echo 'CONFIG_DEBUG_INFO=y' >> {}
    echo 'CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y' >> {}
"

# 2. 修改默认网关 IP (J4125 建议改为 192.168.1.100 避开冲突)
sed -i 's/192.168.1.1/192.168.1.100/g' package/base-files/files/bin/config_generate

# 3. 开启 irqbalance (多核中断负载均衡)
mkdir -p package/base-files/files/etc/uci-defaults
cat <<EOF > package/base-files/files/etc/uci-defaults/99-custom-settings
service irqbalance enable
service irqbalance start
exit 0
EOF

# 4. 强力清理残留的无线组件
sed -i '/wpad/d' .config
sed -i '/hostapd/d' .config
