# Get absolute path of the current script
declare script_file="$(python -c "import os; print(os.path.realpath('$0'))")"
# Get the absolute path of the script enclosing directory
declare script_dir="$(dirname ${script_file})"

echo "This script is running from the directory $script_dir"


# Disable SELinux
setenforce 0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config


# Set up public key for SSH access
mkdir /home/admin/.ssh
chmod 700 /home/admin/.ssh
cat "${script_dir}/config/acit_admin_id_rsa.pub" >> /home/admin/.ssh/authorized_keys
chmod 600 /home/admin/.ssh/authorized_keys


# Install Base packages
yum -y update
yum -y install @core epel-release vim git tcpdump nmap-ncat curl wget


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

mysql -u root < "${script_dir}/config/mariadb_security_config.sql"
systemctl enable mariadb


# PHP Config
yum -y install php php-mysql php-fpm

cp -f "$script_dir/config/php.ini" /etc/php.ini
cp -f "$script_dir/config/www.conf" /etc/php-fpm.d/www.config

systemctl start php-fpm
systemctl enable php-fpm

cp -f $script_dir/config/nginx.conf /etc/nginx/nginx.conf

systemctl restart nginx


# Wordpress DB Config
mysql -u root -p < "${script_dir}/config/wp_mariadb_config.sql"


# Wordpress Configuration

wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp "${script_dir}/config/wp-config.php" /home/admin/wordpress/wp-config.php

sudo rsync -avP wordpress/ /usr/share/nginx/html/
sudo mkdir /usr/share/nginx/html/wp-content/uploads
sudo chown -R admin:nginx /usr/share/nginx/html/*
