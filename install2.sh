#!/bin/bash -e

if [ "$EUID" -ne 0 ]
then echo "Please run as root."
exit
fi

if pgrep -x "RTT" > /dev/null; then
	echo "Tunnel is running!. you must stop the tunnel before update. (pkill RTT)"
    echo "Kiling RTT..."
    sleep 5
    pkill RTT
	echo "Done"
fi

update_os() {
apt-get -o Acquire::ForceIPv4=true update
apt-get -o Acquire::ForceIPv4=true install -y software-properties-common
add-apt-repository --yes universe
add-apt-repository --yes restricted
add-apt-repository --yes multiverse
apt-get -o Acquire::ForceIPv4=true install -y moreutils dnsutils tmux screen nano wget curl socat jq qrencode unzip lsof
}

CHS=3
IRIP=$(dig -4 +short myip.opendns.com @resolver1.opendns.com)
EXIP=0.0.0.0
IRPORT=23-65535
IRPORTTT=443
TOIP=127.0.0.1
TOPORT=multiport


iranserver() {
cat >/etc/systemd/system/tunnel.service <<-EOF
[Unit]
Description=Reverse TLS Tunnel

[Service]
Type=idle
User=root
WorkingDirectory=/root
ExecStart=/root/RTT --iran  --lport:$IRPORT  --sni:$SNI --password:$TOPASS
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl --now enable tunnel.service
systemctl start tunnel.service
}

externalserver() {
cat >/etc/systemd/system/tunnel.service <<-EOF
[Unit]
Description=Reverse TLS Tunnel

[Service]
Type=idle
User=root
WorkingDirectory=/root
ExecStart=/root/RTT --kharej --iran-ip:$EXIP --iran-port:$IRPORTTT --toip:$TOIP --toport:$TOPORT --password:$TOPASS --sni:$SNI --terminate:$TERM
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl --now enable tunnel.service
systemctl start tunnel.service
}

echo "Select Server Location:"
echo "1.Iran(Internal)"
echo "2.kharej(External)"
echo "3.Exit"
read -r -p "Select Number(Default is: 3):" CHS

case $CHS in
    1)
#    echo "Be carefull SSH port must under 23"
#    read -r -p "RTT PASS(Default is: Armani@bash): " TOPASS
#    TOPASS=${TOPASS:-"Armani@bash"}
#    read -r -p "RTT SNI(Default is: cloudflare.com): " SNI
#    SNI=${SNI:-"cloudflare.com"}
#    read -r -p "RTT Restart Time(Default is: 24): " TERM
#    TERM=${TERM:-"24"}
#    sleep 3
#    update_os
#    iranserver
#    echo
#    echo "=== Finished ==="
#    echo
#    sleep 3
#    exit ;;
    echo CHS
    *)   echo "Done."; exit 1 ;;

esac

