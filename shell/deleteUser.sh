serverIp=$1
portSSH=$2
serviceUsername=$3
servicePassword=$4
publicKey=$5

sshpass -p "$password" ssh $username@$ip -p $portSSH "sudo bash ./deleteUser.sh $publicKey"