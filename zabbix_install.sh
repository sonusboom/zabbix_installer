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
  docker run hello-world
  sleep 3
  docker rm $(docker ps -a -q)

# Intialize docker swarm so we can use secrets without using text files

  docker swarm init
  sleep 3  
}

function setup_zabbix () {

# Create directories needed by zabbix container volumes
  echo ""
  echo "Creating required directories for zabbix volumes..."
  echo ""
  mkdir -p -v /zabbix/zbx_env/usr/lib/zabbix/{alertscripts,externalscripts}
  mkdir -p -v /zabbix/zbx_env/usr/share/zabbix/modules
  mkdir -p -v /zabbix/zbx_env/var/lib/zabbix/{export,modules,enc,ssh_keys,mibs,snmptraps}
  mkdir -p -v /zabbix/zbx_env/var/lib/zabbix/ssl/{certs,keys,ssl_ca}
  mkdir -p -v /zabbix/zbx_env/var/lib/mysql
  mkdir -p -v /zabbix/zbx_env/etc/zabbix/zabbix_agentd.d
  mkdir -p -v /zabbix/zbx_env/etc/ssl/nginx
  mkdir -p -v /zabbix/env_vars
  mkdir -p -v /zabbix/{compose,scripts}
  sleep 3

# Create files needed by zabbix environment
  echo ""
  echo "Creating environment files..."
  echo ""
  touch /zabbix/env_vars/{.env_java,.env_web,.env_db_mysql,.env_srv,.env_agent}

 # Add variable to set zabbix-server hostname and port to .env_srv
  echo ""
  echo "Editing .env_srv file..."
  echo ""
cat > /zabbix/env_vars/.env_srv <<-EOF
ZBX_AUTONODEADDRESS=hostname
ZBX_NODEADDRESSPORT=10051
EOF

  sleep 3

# Configure secrets for use by Zabbix Server for MariaDB connections
   
   # Create the MYSQL_USER account this is typically "zabbix"
   read -p "Enter new username for MYSQL_USER: " MYSQL_USER
   echo ""
   # Create the MYSQL_PASSWORD for the MYSQL_USER
   read -p "Enter password for MYSQL_PASSWORD: " MYSQL_PASSWORD
   echo ""
   # Create the MYSQL_ROOT_PASSWORD
   read -p "Enter password MYSQL_ROOT_PASSWORD: " MYSQL_ROOT_PASSWORD

   echo ""
   echo "Creating docker secrets..."
   echo ""
   echo "$MYSQL_USER" | docker secret create MYSQL_USER -
   echo "$MYSQL_PASSWORD" | docker secret create MYSQL_PASSWORD -
   echo "$MYSQL_ROOT_PASSWORD" | docker secret create MYSQL_ROOT_PASSWORD -
   echo ""
   echo "Secrets have been created..."
   docker secret ls
   sleep 3

}

function start_zabbix () {
	
# Run Zabbix as docker stack

   cp docker-compose.yml /zabbix/compose
   docker stack deploy -c /zabbix/compose/docker-compose.yml zabbix
   sleep 5

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
 echo " 3. Start Zabbix"
 echo " q. Quit"
 echo " "
 read -p " Enter your choice: " m_choice

 if [ "$m_choice" = "1" ]; then
	install_docker
 elif [ "$m_choice" = "2" ]; then
	setup_zabbix
 elif [ "$m_choice" = "3" ]; then
	start_zabbix
 elif [ "$m_choice" = "q" ]; then
	clear
	break
 fi

done
