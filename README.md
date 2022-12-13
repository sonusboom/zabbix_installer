# Intro
`zabbix_installer.sh` is a bash script designed to quickly install the docker version of Zabbix (https://www.zabbix.com) 
for testing and/or small scale production purposes.

### Usage
 
The script is menu based and will install and configure Docker as a swarm (so we can use secrets), set up the required volume directories and environment files for Zabbix containers and start the containers as a stack. 

Here are the script installation tasks:

* Install Docker
* Setup Zabbix
* Start Zabbix Stack

The following docker images are deployed via the included docker-compose.yml:

* MariaDB-Server
* Zabbix-Agent
* Zabbix-Java-Gateway
* Zabbix-Server
* Zabbix-Web-Nginx-MySQL

### Compatibility

This script was developed and tested on Ubuntu 22.04 LTS.

### Installation

You can download zabbix_installer.sh by cloning this git repository:
```
git clone https://github.com/sonusboom/zabbix_installer.git
```
    
**To Run:**
```
chmod +x zabbix_installer.sh`
sudo ./zabbix_installer.sh
```

### Important Notice
After you have installed Zabbix, log onto the server and do the following:

1. Click on "Configuration" and then "Hosts"
2. Click on "Zabbix server" and make the following change on "Interfaces"
   - DNS name ```zabbix-agent```
   - "Connect to" click ```DNS```
   - Click ```Update```
3. These changes will allow the Zabbix server to connect to the Zabbix agent  

I am open to suggestions and improvement. Thanks!
