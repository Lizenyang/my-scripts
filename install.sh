#!/bin/bash
# 定义绿色
GREEN='\033[0;32m'
NC='\033[0m'
# 覆盖 echo 命令，加入颜色
echo() {
  command echo -e "${GREEN}$*${NC}"
}

echo "🎉🎉🎉恭喜老板喜提新机🎉🎉🎉"

# 更新APT包列表
sudo apt update
echo "更新完成"
sleep 2

echo "关闭所有防火墙规则"
systemctl stop firewalld.service
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
echo "防火墙已关闭"
sleep 2

# 安装 unzip
#echo "安装 unzip..."
#sudo apt install -y unzip
#echo "unzip已安装"
#sleep 2

# 检查 unzip 是否已安装
if ! command -v unzip &> /dev/null
then
    echo "unzip 未安装，正在安装..."
    sudo apt install -y unzip
else
    echo "unzip 已安装，跳过安装."
fi


# 安装jq
#sudo apt update && sudo apt install -y jq
#echo "jq已安装"
sleep 2

# 检查 jq 是否已安装
if ! command -v jq &> /dev/null
then
    echo "jq 未安装，正在安装..."
    sudo apt update
    sudo apt install -y jq
else
    echo "jq 已安装，跳过安装."
fi

# 安装并执行agent.sh脚本
#echo "安装并执行 agent.sh..."
#curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o agent.sh && chmod +x agent.sh && \
#env NZ_SERVER=138.2.92.42:9981 NZ_TLS=false NZ_CLIENT_SECRET=RMw9rBte3K6MAALtanfPossnw1Z1RwKf ./agent.sh
echo "🎉🎉🎉小鸡已上线🎉🎉🎉"

# 安装 Docker
echo "安装 Docker..."
sudo apt install -y docker.io
echo "docker已安装"
sleep 2

# 安装 Docker Compose
echo "安装 Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 安装  traffmonetizer
#echo "启动 traffmonetizer..."
#docker run --name traa -d traffmonetizer/cli_v2 start accept --token FfS7aIWXg3XZuMO+tiau5Y36klu9j4hY3N7AM3X6f6s
#echo "设置 traa 容器自动重启..."
#docker update --restart=always traa
# 检测系统架构
architecture=$(uname -m)

if [[ "$architecture" == "x86_64" ]]; then
    echo "系统为 x86_64 架构，启动 traffmonetizer..."
    docker run --name traa -d traffmonetizer/cli_v2 start accept --token FfS7aIWXg3XZuMO+tiau5Y36klu9j4hY3N7AM3X6f6s=
elif [[ "$architecture" == "aarch64" ]]; then
    echo "系统为 arm64 架构，拉取 arm64 镜像并启动容器..."
    docker pull traffmonetizer/cli_v2:arm64v8
    docker run -i --name abc -d traffmonetizer/cli_v2:arm64v8 start accept --token FfS7aIWXg3XZuMO+tiau5Y36klu9j4hY3N7AM3X6f6s=
else
    echo "不支持的架构：$architecture"
    exit 1
fi

# 设置容器自动重启
echo "设置容器自动重启..."
docker update --restart=always traa
echo "traffmonetizer设置完成"

## 执行 repocket 命令 
echo "启动 repocket..."
docker run --name repocket -e RP_EMAIL=boss.yangzhen@gmail.com -e RP_API_KEY=2567fdd2-7ca8-4980-ad33-0038676b95d2 -d --restart=always repocket/repocket
echo "repocket启动完成"
sleep 2

echo "设置 repocket 容器自动重启..."
docker update --restart=always repocket

## 执行 earnfm 命令 
echo "启动 earnfm..."
sudo docker stop watchtower; sudo docker rm watchtower; sudo docker rmi containrrr/watchtower; sudo docker stop earnfm-client; sudo docker rm earnfm-client; sudo docker rmi earnfm/earnfm-client:latest; sudo docker run -d --restart=always -e EARNFM_TOKEN="b0698014-763d-41e1-9b99-c891114ad549" --name earnfm-client earnfm/earnfm-client:latest && sudo docker run -d --restart=always --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --include-stopped --include-restarting --revive-stopped --interval 60 earnfm-client
echo "earnfm启动完成"
sleep 2

### 执行 earnfm 命令
echo "启动 PacketStream"
sudo docker run -d --restart=always -e CID=6nYE --name psclient packetstream/psclient:latest 

echo "设置 PacketStream 容器自动重启..."
docker update --restart=always psclient
echo "PacketStream启动完成"
sleep 2

#### 执行 mystnodes 命令
echo "启动 mystnodes"
docker pull mysteriumnetwork/myst && 
docker run --log-opt max-size=10m --cap-add NET_ADMIN -d -p 4449:4449 --name myst -v myst-data:/var/lib/mysterium-node --restart unless-stopped mysteriumnetwork/myst:latest service --agreed-terms-and-conditions
echo "mystnodes启动完成"
sleep 2

##### 执行 Proxyrack 命令
# 生成设备ID
echo "生成设备ID"
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
echo "Proxyrack启动完成"
sleep 2

###### 蜜罐
#docker run honeygain/honeygain -tou-accept -email boss.yangzhen@gmail.com -pass honeygain@931101 -device $(hostname -I | awk '{print $1}')
docker run -d honeygain/honeygain -tou-accept -email boss.yangzhen@gmail.com -pass honeygain@931101 -device $(hostname -I | awk '{print $1}')
echo "蜜罐启动完成"
sleep 2

####### 运行 EarnApp 安装脚本并提取 https:// 链接
https_link=$(wget -qO- https://brightdata.com/static/earnapp/install.sh | sudo bash -s -- -y 2>&1 | grep -o 'https://[^ ]*')
echo "EarnApp启动完成"
sleep 2

# 获取公共IPv4地址
ipv4_address=$(curl -s http://icanhazip.com)

# 输出获取的IPv4地址
echo "Public IPv4 address: $ipv4_address"

# Telegram Bot 配置
bot_token="7830106860:AAF_tDStMZZugfcrl3zWrdARswHMTVLCCok"        # 你的 Telegram Bot Token
chat_id="5553145286"            # 你的 Telegram 用户 ID

# 发送设备ID和IPv4地址到 Telegram
message="IP+4449: $ipv4_address:4449
设备ID是: $device_id 
EarnApp 注册链接：$https_link"
# 对消息进行 URL 编码
encoded_message=$(echo "$message" | jq -sRr @uri)
#send_message="https://api.telegram.org/bot$bot_token/sendMessage?chat_id=$chat_id&text=$message"
send_message_url="https://api.telegram.org/bot$bot_token/sendMessage?chat_id=$chat_id&text=$encoded_message"

# 发送请求
#curl -s "$send_message" > /dev/null
response=$(curl -s "$send_message_url")

echo "老板，都安装完成了,TG也发了，小的退下了。"
