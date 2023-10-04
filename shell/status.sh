ip=$1
portSSH=$2
username=$3
password=$4

ssh -p portSSH -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" user@hostname << EOF
$password
bash status.sh
EOF