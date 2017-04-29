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

<<<<<<< Upstream, based on e54e45d869f74efb4839f6d63f4e982afcd1f49c
=======
##########################################
# install keepalived
##########################################
sudo apt-get -y update
sudo apt-get install keepalived -y

echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind
echo "net.ipv4.ip_nonlocal_bind=1" >> /etc/sysctl.conf
sysctl -p

cp /vagrant/etc/keepalived/keepalived.conf /etc/keepalived/
sed -i "s/%PRIORITY%/$cfg_keepalivepriority1/g" /etc/keepalived/keepalived.conf
sed -i "s/%PASSWORD%/$cfg_keepalivepassword/g" /etc/keepalived/keepalived.conf
sed -i "s/%NODEHOME%/$cfg_keepalivevip/g" /etc/keepalived/keepalived.conf

>>>>>>> 0872f57 upgrade ubuntu 16.04
### [install nginx] ######################
sudo apt-get -y update
sudo apt-get install nginx -y

##########################################
# syslog
##########################################
sed -i 's/#module(load="imudp")/module(load="imudp")/g' /etc/rsyslog.conf
sed -i 's/#input(type="imudp" port="514")/input(type="imudp" port="514")/g' /etc/rsyslog.conf

<<<<<<< Upstream, based on e54e45d869f74efb4839f6d63f4e982afcd1f49c
##########################################
# restart services
##########################################
service rsyslog restart
=======
cat  << 'EOF' > /etc/rsyslog.d/keepalived.conf
if ($programname == 'keepalived') then -/var/log/keepalived.log
EOF

##########################################
# restart services
##########################################
service rsyslog restart
service keepalived stop
service keepalived start
>>>>>>> 0872f57 upgrade ubuntu 16.04

sudo service nginx stop
sudo service nginx start

exit 0

##########################################
# firewall rules
##########################################
mkdir -p /etc/iptables
cp /vagrant/etc/iptables/rules /etc/iptables/rules

sed -i "s/^iptables-restore//g" /etc/network/if-up.d/iptables
sudo sh -c "echo 'iptables-restore < /etc/iptables/rules' >> /etc/network/if-up.d/iptables"
iptables-restore < /etc/iptables/rules

