#!/bin/bash

# 1. 自动定位内核配置文件模板
K_TEMPLATE=$(find target/linux/x86 -name "config-6.6" | head -n 1)

if [ -f "$K_TEMPLATE" ]; then
    echo "正在修复内核模板并补全 DWARF 依赖..."
    # 彻底抹除旧的调试相关配置，防止冲突
    sed -i '/CONFIG_DEBUG_INFO/d' "$K_TEMPLATE"
    
    # 注入全套配置，确保不再触发交互式询问
    {
        echo 'CONFIG_DEBUG_INFO=y'
        echo 'CONFIG_DEBUG_INFO_BTF=y'
        echo 'CONFIG_DEBUG_INFO_BTF_MODULES=y'
        echo 'CONFIG_DEBUG_INFO_REDUCED=n'
        echo 'CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y'
        echo 'CONFIG_DEBUG_INFO_DWARF4=n'
        echo 'CONFIG_DEBUG_INFO_DWARF5=n'
        echo 'CONFIG_KPROBES=y'
        echo 'CONFIG_KPROBE_EVENTS=y'
        echo 'CONFIG_BPF_EVENTS=y'
        echo 'CONFIG_FTRACE=y'
    } >> "$K_TEMPLATE"
fi

# 2. 修改默认 IP
sed -i 's/192.168.1.1/192.168.1.100/g' package/base-files/files/bin/config_generate

# 3. 设置 irqbalance 自启 (uci-defaults 方式最稳)
mkdir -p package/base-files/files/etc/uci-defaults
cat <<EOF > package/base-files/files/etc/uci-defaults/99-custom-settings
/etc/init.d/irqbalance enable
/etc/init.d/irqbalance start
exit 0
EOF
