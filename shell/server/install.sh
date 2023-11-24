username=$1
password=$2
serverIp=$3
portSSH=$4
portWG=$5

sudo apt-get update >/dev/null 2>&1
sudo apt-get upgrade -y >/dev/null 2>&1
sudo apt install wireguard-tools -y >/dev/null 2>&1
sudo apt install sysstat -y >/dev/null 2>&1
sudo ufw allow $portSSH >/dev/null 2>&1
sudo systemctl start ufw >/dev/null 2>&1
sudo systemctl enable ufw >/dev/null 2>&1
sudo journalctl --vacuum-time=1d >/dev/null 2>&1
sudo useradd -d /vpn/shell $username >/dev/null 2>&1
sudo echo "$password
$password" | sudo passwd $username
sudo echo "%sudo ALL=(ALL) NOPASSWD: /usr/bin/wg
$username   ALL=(ALL:ALL) NOPASSWD: ALL">>/etc/sudoers
sudo usermod -aG sudo $username >/dev/null 2>&1
sudo chown -R $username:$username /vpn/shell >/dev/null 2>&1
#sudo chown -R $username:$username /etc/wireguard/
sudo chmod 777 /vpn/shell
sudo systemctl restart ssh.service >/dev/null 2>&1
sudo bash /vpn/shell/createConfig.sh $serverIp $portWG
sudo chown -R $username:$username /etc/wireguard/ >/dev/null 2>&1
sudo wg-quick up wg0 >/dev/null 2>&1
sleep 5
sudo systemctl enable wg-quick@wg0 >/dev/null 2>&1
echo "### Application installed correctly"