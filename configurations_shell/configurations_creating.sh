#! /usr/bin/bash
current_dir="$HOME/vpn"

read -p "Count servers: " count_servers
read -p "Count clients on servers: " count_cliens

# find last folder
max_num=0
for dir in "${current_dir}"/*/; do
    num=$(basename "$dir")
    if [[ "$num" =~ ^[0-9]+$ ]] && ((num > max_num)); then
        max_num=$num
    fi
done
#TODO get ip address from database or file
for ((x=$max_num+1; x<(($count_servers+$max_num+1));x++));do
	ip_address="10.10.10."

	mkdir "$current_dir/$x"
	mkdir "$current_dir/$x/keys"
	mkdir "$current_dir/$x/client_config"
	wg genkey | tee "$current_dir/$x/keys/server_privatekey" | wg pubkey | tee "$current_dir/$x/keys/server_publickey"
	server_privatekey=$(cat "$current_dir/$x/keys/server_privatekey")
	server_publickey=$(cat "$current_dir/$x/keys/server_publickey")
	
	read -p "Server ip address for $x: " server_ip
	read -p "Server interface: " server_interface

#create ufw check
	touch "$current_dir/$x/wg0.conf"
	echo "[Interface]
PrivateKey = $server_privatekey
Address = $server_ip
SaveConfig = true
PostUp = iptables -t nat -I POSTROUTING -o $server_interface -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o $server_interface -j MASQUERADE
PostUp = ufw alllow 62952
PreDown = iptables -t nat -D POSTROUTING -o $server_interface -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o $server_interface -j MASQUERADE
PreDown = ufw delete allow 62952
ListenPort = 62952
" >> "$current_dir/$x/wg0.conf"
	for ((y=1; y<$count_cliens+1;y++));do
		
		wg genkey | tee "$current_dir/$x/keys/client_privatekey" | wg pubkey | tee "$current_dir/$x/keys/client_publickey"
		wg genpsk | tee "$current_dir/$x/keys/client_preshared"

		client_privatekey=$(cat "$current_dir/$x/keys/client_privatekey")
		client_publickey=$(cat "$current_dir/$x/keys/client_publickey")
		client_preshared=$(cat "$current_dir/$x/keys/client_preshared")

		echo "[Peer]
PublicKey = $client_publickey
AllowedIPs = $ip_address$y
PresharedKey = $client_preshared
PersistentKeepalive = 25
" >> "$current_dir/$x/wg0.conf"

		touch "$current_dir/$x/client_config/wg$y.conf"
		echo "[Interface]
Address = $ip_address$y
PrivateKey = $client_privatekey
DNS = 1.1.1.1, 8.8.8.8, 8.8.4.4

[Peer]
PublicKey = $server_publickey
PresharedKey = $client_preshared
PersistentKeepalive = 25
Endpoint = $server_ip:62952
AllowedIPs = 0.0.0.0/0, ::/0
" > "$current_dir/$x/client_config/wg$y.conf"
	done
    cp ./client_remove.py "$current_dir/$x/"
	cp ./autoremove_clients.sh "$current_dir/$x/"
	rm -r "$current_dir/$x/keys/"
done