#testdata: 10.10.10.10 22 64000 user useruser su toor wguser wireguard

configsFolder=$(cat ./configsFolder)
shellFolder=$(pwd)

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

mkdir $configsFolder/$serverIp
mkdir $configsFolder/$serverIp/vpn
mkdir $configsFolder/$serverIp/userConfig/
mkdir $configsFolder/$serverIp/vpn/shell
cp $shellFolder/server/* $configsFolder/$serverIp/vpn/shell

sshpass -p "$password" scp -P $portSSH -r $configsFolder/$serverIp/vpn/ $username@$serverIp:./vpn
sshpass -p "$password" ssh $username@$serverIp -p $portSSH "echo '$suPassowrd' | $suCommand -S cp ./vpn / ; chmod +x /vpn/shell ; bash /vpn/shell/install.sh $serverUsername $serverPassword $serverIp $portSSH $portWG"

# rm -r  $configsFolder/$serverIp/vpn