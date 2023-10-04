pubkey=$1
presharedKey=$2
ip=$3

systemctl stop wg-quick@wg0.service
echo "[Peeer]
PublicKey = $pubkey
PresharedKey = $presharedKey
AllowedIPs = $ip
" >> /etc/wireguard/wg0.conf
systemctl start wg-quick@wg0.service
