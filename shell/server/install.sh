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
sudo useradd -d /vpn/shell $username
echo "$password
$password" | sudo passwd
sudo chown -R $username:$username /vpn/shell
sudo chmod 700 /vpn/shell
sudo systemctl restart ssh.service
bash $PWD/createConfig.sh $serverIp $portWG
sudo systemctl start wg-quick@wg0
sudo systemctl enable wg-quick@wg0