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

/usr/sbin/haproxy -c -V -f /etc/haproxy/haproxy.cfg


##########################################
# install keepalived
##########################################
sudo apt-get install keepalived -y

echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind
echo "net.ipv4.ip_nonlocal_bind=1" >> /etc/sysctl.conf
sysctl -p

cp /vagrant/etc/keepalived/keepalived.conf /etc/keepalived/
sed -i "s/%PRIORITY1%/$cfg_keepalivepriority1/g" /etc/keepalived/keepalived.conf
sed -i "s/%PASSWORD%/$cfg_keepalivepassword/g" /etc/keepalived/keepalived.conf
sed -i "s/%VIP%/$cfg_keepalivevip/g" /etc/keepalived/keepalived.conf

sed -i "s/%MASTER%/MASTER/g" /etc/keepalived/keepalived.conf

##########################################
# firewall rules
##########################################
mkdir -p /etc/iptables
cp /vagrant/etc/iptables/rules /etc/iptables/rules

sed -i "s/^iptables-restore//g" /etc/network/if-up.d/iptables
sudo sh -c "echo 'iptables-restore < /etc/iptables/rules' >> /etc/network/if-up.d/iptables"
iptables-restore < /etc/iptables/rules

##########################################
# syslog
##########################################
sed -i 's/#module(load="imudp")/module(load="imudp")/g' /etc/rsyslog.conf
sed -i 's/#input(type="imudp" port="514")/input(type="imudp" port="514")/g' /etc/rsyslog.conf

cat  << 'EOF' > /etc/rsyslog.d/haproxy.conf
if ($programname == 'haproxy') then -/var/log/haproxy.log
EOF

##########################################
# restart services
##########################################
service rsyslog restart
service haproxy stop
service haproxy start

service keepalived stop
service keepalived start

exit 0
