#!/bin/bash
# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色
# 定义彩色输出函数
color_echo() {
  local color=$1
  shift
  echo -e "${color}$*${NC}"
}
#------------------------------------------------------------------------------------------------------------
color_echo "${GREEN}" "🎉🎉🎉恭喜老板喜提新机🎉🎉🎉"
#------------------------------------------------------------------------------------------------------------
# 更新ALL
# curl 安装
apt install -y sudo
apt update -y  && apt install -y curl
sudo apt-get update -y
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
echo -e "${GREEN}更新完成"
#------------------------------------------------------------------------------------------------------------

# 检测当前优先级配置
gai_conf="/etc/gai.conf"
ipv4_priority_line="precedence ::ffff:0:0/96  100"

if grep -qE "^\s*${ipv4_priority_line}" "$gai_conf"; then
    echo "当前为IPv4优先，无需修改。"
else
    echo "当前为IPv6优先，正在修改为IPv4优先..."
    if grep -qE "^\s*#.*${ipv4_priority_line}" "$gai_conf"; then
        # 如果有注释的IPv4优先设置，取消注释
        sed -i "s|^\s*#\s*\(${ipv4_priority_line}\)|\1|" "$gai_conf"
    else
        # 如果没有对应的设置，则添加
        echo "$ipv4_priority_line" >> "$gai_conf"
    fi
    echo "修改完成，请重新启动网络服务或重启系统。"
fi
#------------------------------------------------------------------------------------------------------------
# 检查是否已配置交换内存
if free | grep -q "Swap"; then
    swap_size=$(free -m | awk '/Swap/ {print $2}')
    if [ "$swap_size" -eq 0 ]; then
        echo "检测到 Swap 已设置，但大小为 0，重新设置为 1GB..."
        sudo swapoff -a
        sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
    else
        echo "检测到 Swap 已设置，大小为 ${swap_size}MB，跳过设置步骤。"
    fi
else
    echo "未检测到 Swap，设置为 1GB..."
    sudo dd if=/dev/zero of=/swapfile bs=1M count=1234
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
fi

# 确保 Swap 永久生效
if ! grep -q "/swapfile" /etc/fstab; then
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
    echo "Swap 已设置为永久生效。"
fi

# 显示当前 Swap 状态
echo "当前 Swap 配置："
free -h
#------------------------------------------------------------------------------------------------------------

#关闭甲骨文防火墙
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F

#------------------------------------------------------------------------------------------------------------
# 安装 Fail2Ban

# 检查系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "无法确定操作系统类型，继续执行..."
fi

# 更新包列表
echo "更新包列表..."
if [[ "$OS" == "Ubuntu" || "$OS" == "Debian" ]]; then
    sudo apt-get update || echo "更新包列表失败，继续执行..."
elif [[ "$OS" == "CentOS Linux" || "$OS" == "Red Hat Enterprise Linux" ]]; then
    sudo yum update -y || echo "更新包列表失败，继续执行..."
else
    echo "不支持的操作系统，继续执行..."
fi

# 安装 Fail2Ban
echo "安装 Fail2Ban..."
if [[ "$OS" == "Ubuntu" || "$OS" == "Debian" ]]; then
    sudo apt-get install -y fail2ban || echo "安装 Fail2Ban 失败，继续执行..."
elif [[ "$OS" == "CentOS Linux" || "$OS" == "Red Hat Enterprise Linux" ]]; then
    sudo yum install -y epel-release || echo "安装 EPEL 仓库失败，继续执行..."
    sudo yum install -y fail2ban || echo "安装 Fail2Ban 失败，继续执行..."
fi

# 启动并启用 Fail2Ban 服务
echo "启动并启用 Fail2Ban 服务..."
sudo systemctl enable fail2ban || echo "启用 Fail2Ban 服务失败，继续执行..."
sudo systemctl start fail2ban || echo "启动 Fail2Ban 服务失败，继续执行..."

# 备份原始配置文件
echo "备份原始配置文件..."
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak || echo "备份配置文件失败，继续执行..."

# 配置 Fail2Ban
echo "配置 Fail2Ban..."
cat <<EOF | sudo tee /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

# 重启 Fail2Ban 服务以应用配置
echo "重启 Fail2Ban 服务以应用配置..."
sudo systemctl restart fail2ban || echo "重启 Fail2Ban 服务失败，继续执行..."

echo "配置完成。"



#------------------------------------------------------------------------------------------------------------
#docker

curl -fsSL https://get.docker.com -o get-docker.sh
yes | sudo sh get-docker.sh

# 验证 Docker 安装
echo "正在验证 Docker 安装..."
sudo docker --version

echo "Docker 安装完成！"

#------------------------------------------------------------------------------------------------------------

# 安装 unzip
echo "正在安装 unzip..."
sudo apt-get install -y unzip
echo "unzip 安装完成！"
#------------------------------------------------------------------------------------------------------------

# 安装 jq
echo "正在安装 jq..."
sudo apt-get install -y jq
echo "jq 安装完成！"
#------------------------------------------------------------------------------------------------------------

# 4. 安装最新版 Node.js
echo "正在安装最新版 Node.js..."
# 下载并运行 NodeSource 安装脚本
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
# 安装 Node.js
sudo apt-get install -y nodejs
echo "Node.js 安装完成！"
#------------------------------------------------------------------------------------------------------------

# 5. 判断系统是否为 ARM64 并安装 qemu-user-static
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo "系统是 ARM64 架构，正在安装 qemu-user-static..."
    sudo apt-get install -y qemu-user-static
    echo "qemu-user-static 安装完成！"
else
    echo "系统不是 ARM64 架构，跳过 qemu-user-static 安装。"
fi
#------------------------------------------------------------------------------------------------------------

# 6. 验证安装
echo "正在验证安装..."
docker --version
unzip -v
jq --version
node -v
npm -v
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    qemu-aarch64-static --version
fi
echo "所有安装已完成并验证成功！"
sleep 3
#------------------------------------------------------------------------------------------------------------
echo "安装traffmonetizer"
# 检测系统架构
architecture=$(uname -m)

if [[ "$architecture" == "x86_64" ]]; then
    echo "系统为 x86_64 架构，启动 traffmonetizer..."
    docker run --name tra -d traffmonetizer/cli_v2 start accept --token FfS7aIWXg3XZuMO+tiau5Y36klu9j4hY3N7AM3X6f6s=
elif [[ "$architecture" == "aarch64" ]]; then
    echo "系统为 arm64 架构，拉取 arm64 镜像并启动容器..."
    docker pull traffmonetizer/cli_v2:arm64v8
    docker run -i --name tra -d traffmonetizer/cli_v2:arm64v8 start accept --token FfS7aIWXg3XZuMO+tiau5Y36klu9j4hY3N7AM3X6f6s=
else
    echo "不支持的架构：$architecture"
    exit 1
fi

# 设置容器自动重启
echo "设置容器自动重启..."
docker update --restart=always tra
echo "traffmonetizer设置完成"
sleep 3
#------------------------------------------------------------------------------------------------------------

## 执行 repocket 命令 
echo "启动 repocket..."
sudo apt install qemu-user-static -y
docker run --name repocket -e RP_EMAIL=boss.yangzhen@gmail.com -e RP_API_KEY=2567fdd2-7ca8-4980-ad33-0038676b95d2 -d --restart=always repocket/repocket -y
echo "repocket启动完成"
sleep 2

echo "设置 repocket 容器自动重启..."
docker update --restart=always repocket
#------------------------------------------------------------------------------------------------------------

## 执行 Earnfm 命令 
echo "启动 earnfm..."
sudo docker stop watchtower; sudo docker rm watchtower; sudo docker rmi containrrr/watchtower; sudo docker stop earnfm-client; sudo docker rm earnfm-client; sudo docker rmi earnfm/earnfm-client:latest; sudo docker run -d --restart=always -e EARNFM_TOKEN="b0698014-763d-41e1-9b99-c891114ad549" --name earnfm-client earnfm/earnfm-client:latest && sudo docker run -d --restart=always --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --include-stopped --include-restarting --revive-stopped --interval 60 earnfm-client
echo "earnfm启动完成"
sleep 2
#------------------------------------------------------------------------------------------------------------

echo "启动 PacketStream"
sudo docker run -d --restart=always -e CID=6nYE --name psclient packetstream/psclient:latest 

echo "设置 PacketStream 容器自动重启..."
docker update --restart=always psclient
echo "PacketStream启动完成"
sleep 2
#------------------------------------------------------------------------------------------------------------

#### 执行 Mystnodes 命令
echo "启动 Mystnodes"
docker pull mysteriumnetwork/myst && 
docker run --log-opt max-size=10m --cap-add NET_ADMIN -d -p 4449:4449 --name mystnodes -v myst-data:/var/lib/mysterium-node --restart unless-stopped mysteriumnetwork/myst:latest service --agreed-terms-and-conditions
echo "mystnodes启动完成"
#sleep 2
#------------------------------------------------------------------------------------------------------------

##### 执行 Proxyrack 命令
# 生成设备ID
echo "生成设备ID"
device_id=$(cat /dev/urandom | LC_ALL=C tr -dc 'A-F0-9' | dd bs=1 count=64 2>/dev/null && echo)

# 使用 docker pull 下载 Proxyrack 镜像
echo "下载 Proxyrack 镜像"
docker pull proxyrack/pop

# 运行 Proxyrack 容器，并将生成的设备ID传递给UUID环境变量
sudo docker run -d --name proxyrack --restart always -e UUID="$device_id" proxyrack/pop
echo "Proxyrack container is running with UUID: $device_id"
echo "Proxyrack启动完成"
sleep 2

#------------------------------------------------------------------------------------------------------------
###### Honeygain
#docker pull honeygain/honeygain
#docker run -d honeygain/honeygain -tou-accept -email boss.yangzhen@gmail.com -pass Honeygain@931101 -device $(hostname -I | awk '{print $1}')
#echo "Honeygain启动完成"
#sleep 2
#------------------------------------------------------------------------------------------------------------

# 获取公共IPv4地址
ipv4_address=$(curl -s http://icanhazip.com)

# 输出获取的IPv4地址
echo "Public IPv4 address: $ipv4_address"

# Telegram Bot 配置
bot_token="7830106860:AAF_tDStMZZugfcrl3zWrdARswHMTVLCCok"        # 你的 Telegram Bot Token
chat_id="5553145286"            # 你的 Telegram 用户 ID

# 发送设备ID和IPv4地址到 Telegram
message="IP+4449: $ipv4_address:4449
设备ID是: $device_id https://peer.proxyrack.com/devices"
#------------------------------------------------------------------------------------------------------------

# 对消息进行 URL 编码
encoded_message=$(echo "$message" | jq -sRr @uri)
#send_message="https://api.telegram.org/bot$bot_token/sendMessage?chat_id=$chat_id&text=$message"
send_message_url="https://api.telegram.org/bot$bot_token/sendMessage?chat_id=$chat_id&text=$encoded_message"

# 发送请求
#curl -s "$send_message" > /dev/null
response=$(curl -s "$send_message_url")

echo "老板，都安装完成了,TG也发了，小的退下了。"
#------------------------------------------------------------------------------------------------------------
