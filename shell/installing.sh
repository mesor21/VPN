#testdata: 10.10.10.10 22 64000 user useruser su toor wguser wireguard

configsFolder=$PWD
shellFolder=$PWD/shell

#преобразование в переменные 
serverIp=$1
portSSH=$2
portWG=$3
username=$4
password=$5
suCommand=$6 
suPassowrd=$7
serverUsername=$8
serverPassword=$9

#serverInterface: ip route | grep default | awk '{print $5}'
mkdir $configsFolder/$serverIp
mkdir $configsFolder/$serverIp/shell
cp ./$shellFolder/status.sh ./$configsFolder/$serverIp

sleep 5