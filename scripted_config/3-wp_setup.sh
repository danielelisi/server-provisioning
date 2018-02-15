# Get absolute path of the current script
declare script_file="$(python -c "import os; print(os.path.realpath('$0'))")"
# Get the absolute path of the script enclosing directory
declare script_dir="$(dirname ${script_file})"


# Disable SELinux
setenforce 0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config


# Install Base packages
yum -y -d1 install @core epel-release vim git tcpdump nmap-ncat curl wget


# Firewall Setup
firewall-cmd --zone=public --permanent --add-port=22/tcp
firewall-cmd --zone=public --permanent --add-port=80/tcp 
firewall-cmd --zone=public --permanent --add-port=443/tcp

systemctl restart firewalld


# NGINX 
yum -y -d1 install nginx
systemctl start nginx
systemctl enable nginx


# MARIADB Config
yum -y -d1 install mariadb-server mariadb
systemctl start mariadb
systemctl enable mariadb

mysql -u root < "${script_dir}/config/mariadb_security_config.sql"


# PHP Config
yum -y -d1 install php php-mysql php-fpm

sed -i -r 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini
sed -i -r 's_listen = 127.0.0.1:9000_listen = /var/run/php-fpm/php-fpm.sock_' /etc/php-fpm.d/www.conf
sed -i -r 's_;listen.owner = nobody_listen.owner = nobody_' /etc/php-fpm.d/www.conf
sed -i -r 's_;listen.group = nobody_listen.group = nobody_' /etc/php-fpm.d/www.conf
sed -i -r 's_user = apache_user = nginx_' /etc/php-fpm.d/www.conf
sed -i -r 's_group = apache_group = nginx_' /etc/php-fpm.d/www.conf


systemctl start php-fpm
systemctl enable php-fpm

cat "${script_dir}/config/nginx.conf" > /etc/nginx/nginx.conf

echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php

systemctl restart nginx


# Wordpress DB Config
mysql -u root < "${script_dir}/config/wp_mariadb_config.sql"


# Wordpress Configuration

wget -P "${script_dir}" http://wordpress.org/latest.tar.gz &> /dev/null
tar xzvf latest.tar.gz &> /dev/null
/bin/cp "${script_dir}/config/wp-config.php" "${script_dir}/wordpress/wp-config.php"

rsync -avP "${script_dir}/wordpress/" /usr/share/nginx/html/ &> /dev/null
mkdir /usr/share/nginx/html/wp-content/uploads
chown -R admin:nginx /usr/share/nginx/html/*

systemctl restart nginx