# Intro
`zabbix_installer.sh` is a bash script designed to quickly install the docker version of Zabbix (https://www.zabbix.com) 
for testing and/or production purposes. It follows the best practices outlined in the MalTrail documentation.

### Additional functions
 
The script allows you to change the MalTrail admin password during installation. It also sets the recommended cronjobs for the MalTrail server and sensor services.

### Compatibility

Currently this script only supports Ubuntu.

### Installation

You can download maltrail_installer.sh by cloning this git repository:
```
git clone https://github.com/sonusboom/maltrail_installer.git
```
    
**To Run:**
```
chmod +x maltrail_installer.sh`
sudo ./maltrail_installer.sh
```

### Important Notice
This script does not set any interfaces to promiscuous mode. You will need to make sure that this is set up prior to installation of the software. I am open to suggestions and improvement. Thanks!
