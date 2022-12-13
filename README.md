# Intro
`zabbix_installer.sh` is a bash script designed to quickly install the docker version of Zabbix (https://www.zabbix.com) 
for testing and/or small scale production purposes.

### Usage
 
The script allows you to change the MalTrail admin password during installation. It also sets the recommended cronjobs for the MalTrail server and sensor services.

The following docker images are deployed:

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
This script does not set any interfaces to promiscuous mode. You will need to make sure that this is set up prior to installation of the software. I am open to suggestions and improvement. Thanks!
