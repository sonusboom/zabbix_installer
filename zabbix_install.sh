#!/bin/bash
#
#
# Script Name: zabbix_install.sh
# Created By: Sonusboom
# Original Date: 12/10/2022
#
#

# ***Check for root user status***

echo "Checking if user is root..."
if [ $(whoami) != "root" ]; then
	echo "Root check failed...please execute script with sudo..."
	exit 1
else
	echo "Root check successful..."
fi

function install_docker () {

# Configure Docker for installation	
  apt-get update
  apt-get install ca-certificates curl gnupg lsb-release
  mkdir -p -v /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  
# Install Docker and run hello-world test and then remove hello-world test
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sleep 3

# Intialize docker swarm so we can use secrets without using text files

  docker swarm init
  sleep 10  
}

function setup_zabbix () {

# Create directories needed by zabbix container volumes
  echo ""
  echo "Creating required directories for zabbix volumes..."
  echo ""
  mkdir -p /zabbix/zbx_env/usr/lib/zabbix/{alertscripts,externalscripts}
  mkdir -p /zabbix/zbx_env/usr/share/zabbix/modules
  mkdir -p /zabbix/zbx_env/var/lib/zabbix/{export,modules,enc,ssh_keys,mibs,snmptraps}
  mkdir -p /zabbix/zbx_env/var/lib/zabbix/ssl/{certs,keys,ssl_ca}
  mkdir -p /zabbix/zbx_env/var/lib/mysql
  mkdir -p /zabbix/zbx_env/etc/zabbix/zabbix_agentd.d
  mkdir -p /zabbix/zbx_env/etc/ssl/{grafana,nginx}
  mkdir -p /zabbix/env_vars
  mkdir -p /zabbix/{compose,scripts}
  mkdir -p /zabbix/zbx_env/grafana/{config,plugins}
  chmod 777 /zabbix/zbx_env/grafana/plugins
  sleep 3

# Create files needed by zabbix environment
  echo ""
  echo "Creating environment files..."
  echo ""
  touch /zabbix/env_vars/{.env_java,.env_web,.env_db_mysql,.env_srv,.env_agent,.env_grafana}
  touch /zabbix/zbx_env/grafana/config/.grafana.ini

 # Add variable to set zabbix-server hostname and port to .env_srv
  echo ""
  echo "Editing .env_srv file..."
  echo ""
cat > /zabbix/env_vars/.env_srv <<-EOF
ZBX_AUTONODEADDRESS=hostname
ZBX_NODEADDRESSPORT=10051
EOF

  sleep 3

cat > /zabbix/env_vars/.env_grafana <<-EOF
GF_INSTALL_PLUGINS=alexanderzobnin-zabbix-app
EOF

  sleep 3

# Configure random secrets for use by Zabbix Server for MariaDB connections
   
   echo ""
   echo "Creating docker secrets..."
   echo ""
   printf "zabbix" | docker secret create MYSQL_USER -  > /dev/null 2>&1
   openssl rand -base64 16 | docker secret create MYSQL_PASSWORD -  > /dev/null 2>&1
   openssl rand -base64 24 | docker secret create MYSQL_ROOT_PASSWORD -  > /dev/null 2>&1
   sleep 3

}

function start_zabbix () {
	
# Run Zabbix as docker stack

   cp docker-compose.yml /zabbix/compose
   docker stack deploy -c /zabbix/compose/docker-compose.yml zabbix
   sleep 5
   echo ""
   echo "Zabbix stack has been started...please wait a few minutes before logging on..."
   echo ""
   echo "Go to http://$(hostname -I |awk '$1 {print $1}'):8080"
   echo ""
   echo "Username: Admin"
   echo "Password: zabbix"
   echo ""
   read -r -s -p $'Press enter to continue...'

}

function clear_zabbix () {

   # stop zabbix stack and remove
   echo '####################################################'
   echo 'Removing Zabbix stack...'
   echo '####################################################'
   docker stack rm zabbix

   # stop all running containers
   echo '####################################################'
   echo 'Stopping running containers...'
   echo '####################################################'
   docker stop $(docker ps -aq)

   # remove all stopped containers
   echo '####################################################'
   echo 'Removing containers ..'
   echo '####################################################'
   docker rm $(docker ps -aq)

   # remove all images
   echo '####################################################'
   echo 'Removing images ...'
   echo '####################################################'
   docker rmi $(docker images -q)

   # remove all stray volumes if any
   echo '####################################################'
   echo 'Removing docker container volumes...'
   echo '####################################################'
   docker volume rm $(docker volume ls -q)

   # clear all secrets
   echo '####################################################'
   echo 'Removing docker secrets...'
   echo '####################################################'
   docker secret rm $(sudo docker secret ls | awk '$2 {print $2}'|awk 'NR!=1')
   echo ""
   echo "Zabbix stack has been removed..."
   echo ""
   read -r -s -p $'Press enter to continue...'


}

m_choice=" "
while [ "$m_choice" != "q" ]
do
 clear
 echo " "
 echo " Zabbix Docker Install"
 echo " "
 echo " 1. Install Docker"
 echo " 2. Setup Zabbix"
 echo " 3. Start Zabbix Stack"
 echo " 4. Clear Zabbix Stack"
 echo " q. Quit"
 echo " "
 read -p " Enter your choice: " m_choice

 if [ "$m_choice" = "1" ]; then
	install_docker
 elif [ "$m_choice" = "2" ]; then
	setup_zabbix
 elif [ "$m_choice" = "3" ]; then
	start_zabbix
 elif [ "$m_choice" = "4" ]; then
	clear_zabbix
 elif [ "$m_choice" = "q" ]; then
	clear
	break
 fi

done
