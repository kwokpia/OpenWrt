#!/bin/bash

# 1. 注入 eBPF/BTF 到内核模板
find target/linux/x86 -name "config-*" | xargs -i sh -c "
    echo 'CONFIG_DEBUG_INFO=y' >> {}
    echo 'CONFIG_DEBUG_INFO_BTF=y' >> {}
    echo 'CONFIG_DEBUG_INFO_BTF_MODULES=y' >> {}
    echo 'CONFIG_KPROBES=y' >> {}
    echo 'CONFIG_KPROBE_EVENTS=y' >> {}
    echo 'CONFIG_BPF_EVENTS=y' >> {}
    echo 'CONFIG_BPF_SYSCALL=y' >> {}
    echo 'CONFIG_BPF_JIT=y' >> {}
"

# 2. 修改默认网关 IP
sed -i 's/192.168.1.1/192.168.1.100/g' package/base-files/files/bin/config_generate

# 3. 设置 irqbalance 自动启动
mkdir -p package/base-files/files/etc/uci-defaults
cat <<EOF > package/base-files/files/etc/uci-defaults/99-custom-settings
service irqbalance enable
service irqbalance start
exit 0
EOF

# 4. 剔除无线残留
sed -i '/wpad/d' .config
sed -i '/hostapd/d' .config
