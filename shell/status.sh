ip=$1
portSSH=$2
username=$3
password=$4

sshpass -p "$password" ssh $username@$ip -p $portSSH "bash ./status.sh"