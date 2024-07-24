#!/bin/bash


#common used variables

LOGFILE="/tmp/frontend.log"


#creating the function to be used all along the script
#Now in the installations we always check whether the command is executed or is it a failure for all the installations

stat() {
    #this would check if the above executed command is pass or failure
    if [ $1 -eq 0 ] ; then #$? this would help us to understand if the above executed code is pass or fail
    echo -e "Success"
else
    echo -e "failure"
fi
}

ID=$(id -u)
if [ $ID -ne 0 ] ; then
    echo -e "Not the root user"
    exit 1
fi


echo "Installing Nginx"
dnf install nginx -y &>> $LOGFILE
stat $?


echo "Enabling the service"
systemctl enable nginx   &>> $LOGFILE
stat $?


echo "enabling the webserver"
systemctl start nginx   &>> $LOGFILE
stat $?



