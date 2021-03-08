#!/bin/bash

# Pull image from Docker Hub, line commented as image will be downloaded anyway with next command
# if there is no local copy

# docker pull myproject/qaauto:latest

# Missing port options, without port(-p) application will not be accessible, 
# We don't know on which port (80,443 or some other port) application is expecting traffic.
#Also I gave name for running container as is easier to work with names then with hash values

docker run -d  --name qaauto -v qalogs:/qaauto/logs myproject/qaauto:latest

# I assumed host has public ip address
# with cURL command we will fetch host's public ip address, 

QUAATO_IP=curl ifconfig.me

#This command will give output of ip address from eth0 NIC, 
#also we can use if our host use private ip address

#QUAATO_IP=$(ip -f inet -o addr show eth0 | cut -d\  -f 7 | cut -d/ -f 1)


# With docker exec we will run test automatisation inside of running container 
docker exec -it qaauto /qhauto/runauto.sh

# We are checking file qhauto-$(date +%Y-%m-%d).log is created or not, as we use volumes,
#we will be able to access file from docker host via /var/lib/docker/volumes/galogs_data/ folder

##############Vars#############

#Location of log file which is used inside of running container

FILENAME=/var/lib/docker/volumes/qalogs/_data/qhauto-$(date +%Y-%m-%d).log

##############Vars#############
##########Functions############

#In this function we can implement return codes for exit, in that case we will know why script exit

function stopremove {
docker stop qaauto
docker rmi qaauto:latest
echo "Docker container is stopped, and image have been removed"
exit
}

##########Functions############

#this if statement is verifying existence of a log file, and is it from today
if [ -f "$FILENAME" ]

then
        echo "Log file have been created, TEST PASSED"

else  
        echo "Log file not created, TEST FAILED!!!"
        stopremove
fi

#Checking how many bytes log file has
#0 (zero) means, file is empty
#everything else, mean file is NOT empty
# FYI word FAIL has 5 bytes

FILESIZE=$(stat -c%s "$FILENAME")

echo "Size of log file: $FILENAME is $FILESIZE byte"

if [ "$FILESIZE" -eq "0" ]

then
     echo "Log file is empty, TEST FAILED!!!, "
     stopremove

else
     echo "Log file is NOT empty"
fi


#Checking if string FAIL exists in log file
if grep -q "FAIL" "$FILENAME"

then
      echo "Failure, TEST FAILED!!!"
      stopremove
else
      echo "Success"
fi

#END OF THE SCRIPT
stopremove
