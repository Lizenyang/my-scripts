#!/bin/bash

# 定义脚本列表
SCRIPTS=(
     "一键流量|https://raw.githubusercontent.com/Lizenyang/my-scripts/main/install.sh && chmod +x install.sh && ./install.sh"
    "禁SSH爆破丨https://raw.githubusercontent.com/Lizenyang/my-scripts/main/fail2ban.sh && chmod +x fail2ban.sh && ./fail2ban.sh"
    "测试丨https://raw.githubusercontent.com/Lizenyang/my-scripts/main/fail2ban.sh && chmod +x fail2ban.sh && ./fail2ban.sh"
)

# 显示菜单
echo "请选择要运行的脚本："
for i in "${!SCRIPTS[@]}"; do
    echo "$((i+1)). ${SCRIPTS[$i]##*/}"
done
echo "0. 退出"

# 读取用户输入
read -p "请输入选项编号: " choice

# 检查输入是否有效
if [[ $choice -ge 1 && $choice -le ${#SCRIPTS[@]} ]]; then
    script_url=${SCRIPTS[$((choice-1))]}
    echo "正在下载并运行脚本: ${script_url##*/}"
    bash <(curl -sSL $script_url)
elif [[ $choice -eq 0 ]]; then
    echo "退出脚本。"
else
    echo "无效选项，请重新运行脚本。"
fi
