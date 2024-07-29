#!/bin/bash



ID=$(id -u)
if [ $ID -ne 0 ] ; then
    echo -e "Not the root user"
    exit 1
fi

COMPONENT="frontend"
LOGFILE="/tmp/$COMPONENT.log"


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
sed -i -e "/$COMPONENT/s/localhost/mongodb.roboshop.internal/" /etc/nginx/default.d/roboshop.conf
stat $?

echo "Restarting the service"
systemctl start nginx   &>> $LOGFILE
stat $?


#sudo bash wrapper.sh frontend