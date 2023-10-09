username=$1
password=$2
serverIp=$3
portSSH=$4
portWG=$5

sudo apt-get update
sudo apt-get upgrade -y
sudo apt install wireguard-tools -y
sudo apt install ufw -y
sudo ufw allow $portSSH
sudo ufw allow $portWG
sudo ufw allow in on wg0 to any
sudo systemctl start ufw
sudo systemctl enable ufw
sudo journalctl --vacuum-time=1d
sudo useradd $username -p $(openssl passwd -1 $password)
sudo usermod -d /vpn/shell -s /vpn/shell $username
sudo systemctl restart ssh.service
bash $PWD/createConfig.sh $serverIp $portWG
mv ./wg0.conf /etc/wireguard/
sudo systemctl start wg-quick@wg0
sudo systemctl enable wg-quick@wg0