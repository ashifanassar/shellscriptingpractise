#!/bin/bash

ID=$(id -u)
if [ $ID -ne 0 ] ; then
    echo -e "Not the root user"
    exit 1
fi

COMPONENT="catalogue"
LOGFILE="/tmp/$COMPONENT.log"
APPUSER="roboshop"
APPUSER_DIR="/home/roboshop/${COMPONENT}"

stat() {
    #this would check if the above executed command is pass or failure
    if [ $1 -eq 0 ] ; then #$? this would help us to understand if the above executed code is pass or fail
    echo -e "Success"
else
    echo -e "failure"
    fi
}

echo -e "Disabling the default nodejs"
dnf module disable nodejs -y &>> $LOGFILE
stat $?

echo -e "enabling the nodejs18"
dnf module enable nodejs:18 -y &>> $LOGFILE
stat $?

echo -e "Install nodejs:18"
dnf install nodejs -y &>> $LOGFILE
stat $?


echo -e "creating the $APPUSER user account"
id $APPUSER &>> $LOGFILE
if [ $1 -ne 0 ] ; then #$? this would help us to understand if the above executed code is pass or fail
    useradd $APPUSER
    echo -e "Success"
    stat $?
else
    echo -e "Skipping the user creation"
fi
stat $?


echo -e "Downloading the $COMPONENT component:"
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -e "Performing $COMPONENT cleanup"
rm -rf ${APPUSER_DIR}  &>> $LOGFILE
stat $?


echo -e "Extracting $APPUSER"
cd /home/roboshop
unzip -o /tmp/catalogue.zip   &>> $LOGFILE
stat $?


echo -e "Configuring the permissions"
mv $APPUSER_DIR-main $APPUSER_DIR
chown -R ${APPUSER}:${APPUSER} ${APPUSER_DIR}
stat $?

echo -e "Generating the artifacts"
cd $APPUSER_DIR
npm install &>> $LOGFILE
stat $?

echo -e "Replacing the IP address of the machine with DNS"
sed -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' ${APPUSER_DIR}/systemd.service
mv ${APPUSER_DIR}/systemd.service /etc/systemd/system/${COMPONENT}.service
stat $?

echo -e "Starting the service"
systemctl eable $COMPONENT   &>> $LOGFILE
systemctl restart $COMPONENT  &>> $LOGFILE
stat $?

#sudo bash wrapper.sh catalogue