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
# install haproxy
##########################################
apt-get -y update
apt-get -y upgrade
apt-get install haproxy -y

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_ori
cp /vagrant/etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg 

sed -i "s/NODE1/$cfg_ip_node1/g" /etc/haproxy/haproxy.cfg
sed -i "s/NODE2/$cfg_ip_node2/g" /etc/haproxy/haproxy.cfg
sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/haproxy

/usr/sbin/haproxy -c -V -f /etc/haproxy/haproxy.cfg

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
sudo apt-get install ganglia-monitor -y

sudo cp /vagrant/etc/ganglia/gmond.conf /etc/ganglia/gmond.conf
sudo sed -i "s/MONITORNODE/$cfg_ganglia_server/g" /etc/ganglia/gmond.conf
sudo sed -i "s/THISNODEID/$cfg_ip_nodehome/g" /etc/ganglia/gmond.conf
sudo /etc/init.d/ganglia-monitor restart

##########################################
# syslog
##########################################
sed -i 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
sed -i 's/#$UDPServerAddress 127.0.0.1/$UDPServerAddress 127.0.0.1/g' /etc/rsyslog.conf
sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf

cat  << 'EOF' > /etc/rsyslog.d/haproxy.conf
if ($programname == 'haproxy') then -/var/log/haproxy.log
EOF

##########################################
# restart services
##########################################
service rsyslog restart
service haproxy stop
service haproxy start

exit 0
