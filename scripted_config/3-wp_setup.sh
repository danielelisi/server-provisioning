# Install Base packages

yum -y install epel-release vim git tcpdump nmap-ncat curl

# Firewall Setup
firewall-cmd --zone=public --permanent --add-port=22/tcp
firewall-cmd --zone=public --permanent --add-port=80/tcp 
firewall-cmd --zone=public --permanent --add-port=443/tcp

# NGINX 
yum -y install nginx
systemctl start nginx
systemctl enable nginx

# MARIADB Config
yum -y install mariadb-server mariadb
systemctl start mariadb
systemctl enable mariadb

mysql -u root < mariadb_security_config.sql
systemctl enable mariadb

# PHP Config
yum -y install php php-mysql php-fpm

systemctl start php-fpm
systemctl enable php-fpm

# Wordpress Configuration
wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php

sudo rsync -avP wordpress/ /usr/share/nginx/html/
sudo mkdir /usr/share/nginx/html/wp-content/uploads
sudo chown -R admin:nginx /usr/share/nginx/html/*

# Install VirtualBox Additions
yum -y install kernel-devel kernel-headers dkms gcc gcc-c++ kexec-tools
mkdir vbox_cd
mount /dev/cdrom ./vbox_cd

