#!/bin/bash

# 检查系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "无法确定操作系统类型。"
    exit 1
fi

# 更新包列表
echo "更新包列表..."
if [[ "$OS" == "Ubuntu" || "$OS" == "Debian" ]]; then
    sudo apt-get update || { echo "更新包列表失败。"; exit 1; }
elif [[ "$OS" == "CentOS Linux" || "$OS" == "Red Hat Enterprise Linux" ]]; then
    sudo yum update -y || { echo "更新包列表失败。"; exit 1; }
else
    echo "不支持的操作系统。"
    exit 1
fi

# 安装 Fail2Ban
echo "安装 Fail2Ban..."
if [[ "$OS" == "Ubuntu" || "$OS" == "Debian" ]]; then
    sudo apt-get install -y fail2ban || { echo "安装 Fail2Ban 失败。"; exit 1; }
elif [[ "$OS" == "CentOS Linux" || "$OS" == "Red Hat Enterprise Linux" ]]; then
    sudo yum install -y epel-release
    sudo yum install -y fail2ban || { echo "安装 Fail2Ban 失败。"; exit 1; }
fi

# 启动并启用 Fail2Ban 服务
echo "启动并启用 Fail2Ban 服务..."
sudo systemctl enable fail2ban || { echo "启用 Fail2Ban 服务失败。"; exit 1; }
sudo systemctl start fail2ban || { echo "启动 Fail2Ban 服务失败。"; exit 1; }

# 备份原始配置文件
echo "备份原始配置文件..."
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak

# 配置 Fail2Ban
echo "配置 Fail2Ban..."
cat <<EOF | sudo tee /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = -1
EOF

# 重启 Fail2Ban 服务以应用配置
echo "重启 Fail2Ban 服务以应用配置..."
sudo systemctl restart fail2ban || { echo "重启 Fail2Ban 服务失败。"; exit 1; }

echo "配置完成。"
