#!/bin/bash
read -p 'Count mouths: ' months
read -p 'IP address: ' ip
future_date="$(date -d "$future_date" +'%M %H %d %m') *"
(sudo crontab -l ; echo "$future_date sudo wg-quick down wg0 && sudo python3 /root/client_remove.py /etc/wireguard/wg0.conf $ip && sudo wg-quick down wg0") | sudo crontab -