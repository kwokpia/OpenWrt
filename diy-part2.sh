#!/bin/bash

# 1. 修改默认 IP
sed -i 's/192.168.1.1/192.168.1.100/g' package/base-files/files/bin/config_generate

# 2. 【核心修复】地毯式修改所有 x86 内核模板
# 24.10 的模板分布在 generic, x86, 和 x86/64
find target/linux/x86 target/linux/generic -name "config-6.6" | xargs -i sh -c "
    echo '正在强力修改内核模板: {}'
    # 先抹除所有冲突项
    sed -i '/CONFIG_DEBUG_INFO/d' {}
    sed -i '/CONFIG_DEBUG_INFO_REDUCED/d' {}
    sed -i '/CONFIG_DEBUG_INFO_BTF/d' {}
    
    # 注入强制开启项 (确保 BTF 生效的所有依赖链)
    {
        echo 'CONFIG_DEBUG_INFO=y'
        echo 'CONFIG_DEBUG_INFO_BTF=y'
        echo 'CONFIG_DEBUG_INFO_BTF_MODULES=y'
        echo 'CONFIG_DEBUG_INFO_REDUCED=n'
        echo 'CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y'
        echo 'CONFIG_KPROBES=y'
        echo 'CONFIG_BPF_EVENTS=y'
        echo 'CONFIG_FTRACE=y'
    } >> {}
"

# 3. 强制开启 irqbalance 自启
mkdir -p package/base-files/files/etc/uci-defaults
echo "service irqbalance enable && service irqbalance start" > package/base-files/files/etc/uci-defaults/99-custom-settings
