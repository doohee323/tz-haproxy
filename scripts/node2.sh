sudo su
set -x

echo "Reading config...." >&2
source /vagrant/setup.rc

export DEBIAN_FRONTEND=noninteractive

export USER=vagrant  # for vagrant
export HOME_DIR=/home/$USER
export PROJ_DIR=/vagrant

sudo sh -c "echo '' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export PATH=$PATH:.' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export HOME_DIR='$HOME_DIR >> $HOME_DIR/.bashrc"
source $HOME_DIR/.bashrc

##########################################
# install keepalived
##########################################
sudo apt-get install keepalived -y

echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind
echo "net.ipv4.ip_nonlocal_bind=1" >> /etc/sysctl.conf
sysctl -p

cp /vagrant/etc/keepalived/keepalived.conf /etc/keepalived/
sed -i "s/%PRIORITY%/$cfg_keepalivepriority2/g" /etc/keepalived/keepalived.conf
sed -i "s/%PASSWORD%/$cfg_keepalivepassword/g" /etc/keepalived/keepalived.conf
sed -i "s/%NODEHOME%/$cfg_nodehome/g" /etc/keepalived/keepalived.conf

### [install nginx] ######################
sudo apt-get install nginx -y

##########################################
# firewall rules
##########################################
mkdir -p /etc/iptables
cp /vagrant/etc/iptables/rules /etc/iptables/rules

sed -i "s/^iptables-restore//g" /etc/network/if-up.d/iptables
sudo sh -c "echo 'iptables-restore < /etc/iptables/rules' >> /etc/network/if-up.d/iptables"
iptables-restore < /etc/iptables/rules

##########################################
# install ganglia
##########################################
apt-get install ganglia-monitor -y

sudo cp /vagrant/etc/ganglia/gmond.conf /etc/ganglia/gmond.conf
sudo sed -i "s/MONITORNODE/$cfg_ganglia_server/g" /etc/ganglia/gmond.conf
sudo sed -i "s/THISNODEID/$cfg_ip_node2/g" /etc/ganglia/gmond.conf
sudo /etc/init.d/ganglia-monitor restart

##########################################
# syslog
##########################################
sed -i 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
sed -i 's/#$UDPServerAddress 127.0.0.1/$UDPServerAddress 127.0.0.1/g' /etc/rsyslog.conf
sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf

cat  << 'EOF' > /etc/rsyslog.d/keepalived.conf
if ($programname == 'keepalived') then -/var/log/keepalived.log
EOF

##########################################
# restart services
##########################################
service rsyslog restart
service keepalived stop
service keepalived start

sudo service nginx stop
sudo nginx -s stop
sudo nginx

exit 0
