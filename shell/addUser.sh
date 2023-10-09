ip=$1
portSSH=$2
portWG=$3
username=$4
password=$5
id=$6
vpnIp=$7
server_publickey=$8

wg genkey | tee "$PWD/$ip/client_privatekey" | wg pubkey | tee "$PWD/$ip/client_publickey"
wg genpsk | tee "$PWD/$ip/client_preshared"

mkdir $PWD/$ip/keys
client_privatekey=$(cat "$PWD/$ip/keys/client_privatekey")
client_publickey=$(cat "$PWD/$ip/keys/client_publickey")
client_preshared=$(cat "$PWD/$ip/keys/client_preshared")
rm -r $PWD/$ip/keys

touch "PWD/$ip/userConfig/$id.conf"
echo "[Interface]
Address = $ip
PrivateKey = $client_privatekey
DNS = 1.1.1.1, 8.8.8.8, 8.8.4.4

[Peer]
PublicKey = $server_publickey
PresharedKey = $client_preshared
PersistentKeepalive = 25
Endpoint = $server_ip:$portWG
AllowedIPs = 0.0.0.0/0, ::/0
" > "$current_dir/$x/client_config/wg$y.conf"

sshpass -p "$password" ssh $username@$ip -p $portSSH "bash ./createUser.sh $client_publickey $client_preshared $ip"