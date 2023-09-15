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
PreDown = iptables -t nat -D POSTROUTING -o $server_interface -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o $server_interface -j MASQUERADE
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
	touch "$current_dir/$x/client_remove.py"
echo "import sys

def remove_peer_by_allowed_ips(config_file, allowed_ips):
    with open(config_file, 'r') as f:
        lines = f.readlines()

    with open(config_file, 'w') as f:
        found_peer = False
        i = 0
        while i < len(lines):
            line = lines[i]
            if line.strip().startswith('[Peer]'):
                peer_lines = []
                j = i + 1
                while j < len(lines) and not lines[j].strip().startswith('['):
                    peer_lines.append(lines[j])
                    j += 1
                peer_allowed_ips = [line for line in peer_lines if line.strip().startswith('AllowedIPs')]
                if peer_allowed_ips and allowed_ips in peer_allowed_ips[0]:
                    found_peer = True
                else:
                    f.write('[Peer]\n')
                    f.writelines(peer_lines)
            else:
                f.write(line)
            i = j if 'j' in locals() else i + 1

    return found_peer

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: python client_remove.py <config_file> <allowed_ips>')
        sys.exit(1)

    config_file = sys.argv[1]  
    allowed_ips = sys.argv[2]

    removed = remove_peer_by_allowed_ips(config_file, allowed_ips)
    if removed:
        print(f'Peer with AllowedIPs {allowed_ips} removed from {config_file}')
    else:
        print(f'No matching peer found with AllowedIPs {allowed_ips} in {config_file}')
" > "$current_dir/$x/client_remove.py"
	touch $current_dir/$x/remove_client.sh
	echo "#!/bin/bash
read -p 'Count mouths: ' months
read -p 'IP address: ' ip
future_date="$(date -d "$future_date" +'%M %H %d %m') *"
(sudo crontab -l ; echo \"\$future_date sudo wg-quick down wg0 && sudo python3 /root/client_remove.py /etc/wireguard/wg0.conf \$ip && sudo wg-quick down wg0\") | sudo crontab -" > $current_dir/$x/remove_client.sh
	rm -r "$current_dir/$x/keys/"
done