#!/bin/bash

# 1. 修改默认 IP
sed -i 's/192.168.1.1/192.168.1.100/g' package/base-files/files/bin/config_generate

# 2. 【核心修复】直接修改内核模板 (target/linux/x86/config-6.6)
# 这是唯一能保证 BTF 选项被内核编译器看到的方法
K_TEMPLATE="target/linux/x86/config-6.6"
if [ -f "$K_TEMPLATE" ]; then
    echo "正在强制修改内核模板: $K_TEMPLATE"
    # 先删除冲突项
    sed -i '/CONFIG_DEBUG_INFO/d' "$K_TEMPLATE"
    sed -i '/CONFIG_DEBUG_INFO_REDUCED/d' "$K_TEMPLATE"
    sed -i '/CONFIG_DEBUG_INFO_BTF/d' "$K_TEMPLATE"
    
    # 注入强制开启项
    {
        echo 'CONFIG_DEBUG_INFO=y'
        echo 'CONFIG_DEBUG_INFO_BTF=y'
        echo 'CONFIG_DEBUG_INFO_BTF_MODULES=y'
        echo 'CONFIG_DEBUG_INFO_REDUCED=n'
        echo 'CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y'
    } >> "$K_TEMPLATE"
else
    echo "警告: 未找到内核模板 $K_TEMPLATE，尝试查找通用 x86 模板"
    find target/linux/x86 -name "config-*" | xargs -i sh -c "echo 'CONFIG_DEBUG_INFO_BTF=y' >> {}"
fi

# 3. 设置 irqbalance 自启
mkdir -p package/base-files/files/etc/uci-defaults
echo "service irqbalance enable && service irqbalance start" > package/base-files/files/etc/uci-defaults/99-custom-settings
