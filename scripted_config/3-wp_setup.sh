# get the abosolute path of the current script 
declare script_path="$(python -c "import os; print(os.path.realpath('$0'))")"

# get the path of its enclosing directory us this to setup relative paths
declare script_dir="$(dirname ${script_path})"

# Disable SELinux
setenforce 0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config

# Install Base packages
yum -y update
yum -y install epel-release vim git tcpdump nmap-ncat curl

# Firewall Setup
firewall-cmd --zone=public --permanent --add-port=22/tcp
firewall-cmd --zone=public --permanent --add-port=80/tcp 
firewall-cmd --zone=public --permanent --add-port=443/tcp

systemctl restart firewalld

# NGINX 
yum -y install nginx
systemctl start nginx
systemctl enable nginx

# MARIADB Config
yum -y install mariadb-server mariadb
systemctl start mariadb

mysql -u root < mariadb_security_config.sql
systemctl enable mariadb

# PHP Config
yum -y install php php-mysql php-fpm

cp -f /home/admin/php.ini /etc/php.ini
cp -f /home/admin/www.conf /etc/php-fpm.d/www.config

systemctl start php-fpm
systemctl enable php-fpm

cp -f /home/admin/nginx.conf /etc/nginx/nginx.conf

systemctl restart nginx

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

