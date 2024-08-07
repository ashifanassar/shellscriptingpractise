#!/bin/bash


source components/common.sh #source will keep all the functions


COMPONENT="frontend"
LOGFILE="/tmp/$COMPONENT.log"


#creating the function to be used all along the script
#Now in the installations we always check whether the command is executed or is it a failure for all the installations






echo "Installing Nginx"
dnf install nginx -y &>> $LOGFILE
stat $?


echo "Enabling the service"
systemctl enable nginx   &>> $LOGFILE
stat $?


echo "enabling the webserver"
systemctl start nginx   &>> $LOGFILE
stat $?

echo "Downloading the $COMPONENT"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?


echo "Cleanup of the $COMPONENT component"
cd /usr/share/nginx/html
rm -rf * &>> $LOGFILE
stat $?

echo "extracting the $COMPONENT"
unzip /tmp/frontend.zip &>> $LOGFILE
stat $?

echo "configuring the $COMPONENT"
mv $COMPONENT-main/*   &>> $LOGFILE
mv static/*  &>> $LOGFILE
rm -rf $COMPONENT-main README.md  &>> $LOGFILE
mv localhost.conf /etc/nginx/default.d/roboshop.conf
stat $?

echo -n "updating the reverse proxy file"
    for i in catalogue user cart shipping; do
sed -i -e "/$i/s/localhost/ $i.roboshop.internal/" /etc/nginx/default.d/roboshop.conf
stat $?

echo "Restarting the service"
systemctl start nginx   &>> $LOGFILE
stat $?


#sudo bash wrapper.sh frontend