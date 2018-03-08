#!/bin/sh

#log to journal showing script start
systemd-cat -p "notice" -t wp_mariadb_config printf "%s" "wp_mariadb_config.sh start" 

#execute wp_mariadb_config.sql statements as the root mysql user, 
#remember password for root hasn't been set yet

# systemd or init script is passing a different path than is defined in the my.cnf file for the socket
# I'm using '127.0.0.1' so mysql uses the TCP/IP connector instead of 'localhost' using socket connector 
mysql -h 127.0.0.1 -u root < "mariadb_security_config.sql"
mysql -h 127.0.0.1 -u root < "wp_mariadb_config.sql"

#Disable the wp_mariadb_config.service
systemctl disable wp_mariadb_config.service

#log to journal showing script end
systemd-cat -p "notice" -t wp_mariadb_config printf "%s" "wp_mariadb_config.sh end" 
