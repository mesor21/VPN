serverIp=$1
portWG=$2

mkdir keys
wg genkey | tee "$PWD/keys/server_privatekey" | wg pubkey | tee "$PWD/keys/server_publickey"
server_privatekey=$(cat "$PWD/keys/server_privatekey")
server_publickey=$(cat "$PWD/keys/server_publickey")
rm -r keys

server_interface=$(ip route | grep default | awk '{print $5}')

sudo touch /etc/wireguard/wg0.conf
sudo echo "[Interface]
PrivateKey = $server_privatekey
Address = $serverIp
SaveConfig = true
PostUp = iptables -t nat -I POSTROUTING -o $server_interface -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o $server_interface -j MASQUERADE
PostUp = ufw allow $portWG
PreDown = iptables -t nat -D POSTROUTING -o $server_interface -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o $server_interface -j MASQUERADE
PreDown = ufw delete allow $portWG
ListenPort = $portWG
">>/etc/wireguard/wg0.conf