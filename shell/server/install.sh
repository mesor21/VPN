username=$1
password=$2
serverIp=$3
portSSH=$4
portWG=$5

sudo apt-get update
sudo apt-get upgrade -y
sudo apt install wireguard-tools -y
sudo apt install sysstat -y
sudo ufw allow $portSSH
sudo systemctl start ufw
sudo systemctl enable ufw
sudo journalctl --vacuum-time=1d
sudo useradd -d /vpn/shell $username
echo "$password
$password" | sudo passwd $username
echo '$username ALL=(ALL) NOPASSWD: /usr/bin/wg'>>/etc/sudoers
sudo chown -R $username:$username /vpn/shell
sudo chown -R $username:$username /etc/wireguard/
sudo chmod 777 /vpn/shell
sudo systemctl restart ssh.service
sudo bash /vpn/shell/createConfig.sh $serverIp $portWG
sudo wg-quick up wg0
sudo systemctl start wg-quick@wg0
sudo systemctl enable wg-quick@wg0