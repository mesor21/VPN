#! /usr/bin/bash
read -p "Road wg server config: " wg_config_file
read -p "Ssh key(optional): " ssh_key
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install apt install openssh-server
sudo mkdir /root/.ssh/
if [[ -n $ssh_key ]]; then
	sudo mv $ssh_key /root/.ssh/
fi
sudo apt install wireguard-tools -y
sudo apt install ufw -y
sudo ufw allow 62952
sudo ufw allow 61234
sudo ufw allow in on wg0 to any
sudo systemctl start ufw
sudo systemctl enable ufw
sudo echo "
Include /etc/ssh/sshd_config.d/*.conf
port 61234
PasswordAuthentication no
MaxAuthTries 3
MaxSessions 2
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server" > /etc/ssh/sshd_config 
sudo service ssh restart
sudo mv $wg_config_file /etc/wireguard/
sudo systemctl start wg-quick@wg0
sudo systemctl enable wg-quick@wg0
sudo systemctl stop	plymounth
sudo systemctl stop	plymounth-log
sudo systemctl disable plymounth
sudo systemctl disable plymounth-log
sudo touch /etc/cron.daily/clear_logs.sh
sudo journalctl --vacuum-time=1d
sudo echo "NOW=$(date)
date -s "2015-02-12 09:09:11"
rm -r /var/log/*
sudo rm /root/.ssh/known_hosts*
sudo rm /home/lol/.ssh/known_hosts*
echo > /var/log/wtmp
echo > /var/log/btmp
echo > /var/log/lastlog
echo > /var/log/apt/history.log
date -s '$NOW'
history -r
sudo apt-get update" > /etc/cron.daily/clear_logs.sh

echo "done"