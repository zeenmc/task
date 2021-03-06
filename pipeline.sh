#!/bin/bash

# Pull image from Docker Hub, line commented as image will be downloaded anyway with next command
# if there is no local copy

# docker pull myproject/qaauto:latest


# Missing port options, without port(-p) application will not be accessible, 
# We don't know on which port (80,443 or some other port) application is expecting traffic
#Also I give name for running container as is easier to work with names then with hash values

docker run -d  --name qaauto -v qalogs:/qaauto/logs myproject/qaauto:latest

# I assumed host has public ip address
# with cURL command we will fetch host's public ip address, 
# in case of private ip address, we will use regularex to find output
# from ifconfig or ip add show

QUAATO_IP = curl ifconfig.me


# With docker exec we will run test automatisation inside of running container 
docker exec -it qaauto /qhauto/runauto.sh

# We are checking file qhauto-$(date +%Y-%m-%d).log is created or not, as we use volumes,
#we will be able to access file from docker host via /var/lib/docker/volumes/galogs_data/ folder

##############Vars#############

#Location of log file which is used inside of running container

FILENAME=/var/lib/docker/volumes/qalogs/_data/qhauto-$(date +%Y-%m-%d).log

##############Vars#############
##########Functions############

function stopremove {
docker stop qaauto
docker rmi qaauto:latest
exit
}

##########Functions############

if [ -f /var/lib/docker/volumes/qalogs/_data/qhauto-$(date +%Y-%m-%d).log ]

then
        echo "Log file have been created, TEST PASSED"

else  
        echo "Log file not created, TEST FAILED!!!"
        stopremove
fi


FILESIZE=$(stat -c%s "$FILENAME")

echo "Size of log file: $FILENAME is $FILESIZE byte"

if [ "$FILESIZE" -eq "0" ]

then
     echo "file is empty, TEST FAILED!!!, "
     stopremove

else
     echo "file is NOT empty"
fi


#Checking if string FAIL exists in log file
if grep -q "FAIL" $FILENAME

then
      echo "Failure, TEST FAILED!!!"
      stopremove
else
      echo "Success"
fi


stopremove
