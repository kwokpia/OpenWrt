#!/bin/bash

# 1. 注入 eBPF/BTF 到内核模板 (针对 24.10 内核 6.6)
# 这是解决 BTF 不显示的关键：必须改模板文件而非当前 .config
find target/linux/x86 -name "config-*" | xargs -i sh -c "
    echo 'CONFIG_DEBUG_INFO_BTF=y' >> {}
    echo 'CONFIG_DEBUG_INFO_BTF_MODULES=y' >> {}
    echo 'CONFIG_BPF_EVENTS=y' >> {}
    echo 'CONFIG_KPROBES=y' >> {}
    echo 'CONFIG_KPROBE_EVENTS=y' >> {}
    echo 'CONFIG_DEBUG_INFO=y' >> {}
    echo 'CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y' >> {}
"

# 2. 设置 irqbalance 默认启动 (使用 uci-defaults 脚本)
mkdir -p package/base-files/files/etc/uci-defaults
cat <<EOF > package/base-files/files/etc/uci-defaults/99-custom-settings
service irqbalance enable
service irqbalance start
exit 0
EOF

# 3. 强力剔除无线组件 (防止编译时自动拉取)
sed -i '/wpad/d' .config
sed -i '/hostapd/d' .config
sed -i '/iwinfo/d' .config

# 4. 修改默认 IP 为 192.168.1.100 (可选，解决 IP 冲突)
sed -i 's/192.168.1.1/192.168.1.100/g' package/base-files/files/bin/config_generate
