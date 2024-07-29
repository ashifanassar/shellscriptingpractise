#!/bin/bash

ID=$(id -u)
if [ $ID -ne 0 ] ; then
    echo -e "Not the root user"
    exit 1
fi

COMPONENT="mongodb"
LOGFILE="/tmp/$COMPONENT.log"
MONGO_REPO= "https://raw.githubusercontent.com/stans-robot-project/${COMPONENT}/main/mongo.repo"
MONGO_SCHEMA=""https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"


stat() {
    #this would check if the above executed command is pass or failure
    if [ $1 -eq 0 ] ; then #$? this would help us to understand if the above executed code is pass or fail
    echo -e "Success"
else
    echo -e "failure"
fi
}

echo -e "configuring the repos"
curl -s -o /etc/yum.repos.d/${COMPONENT}.repo ${MONGO_REPO} &>>${LOGFILE}
stat $?

echo -e "Intall the mongodb"
dnf install -y mongodb-org  &>>${LOGFILE}
stat $?

echo -e "Enable the mongodb"
systemctl enable mongod   &>>${LOGFILE}
stat $?


echo -e "Start the mongodb"
systemctl start mongod  &>>${LOGFILE}
stat $?

echo -e "Enabling the mongodb visibility"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf


echo -n "starting $COMPONENT service"
systemctl restart mongod &>> $LOGFILE
stat $?



echo -n "Downloading the  $COMPONENT schema file"
curl -s -L -o /tmp/mongodb.zip ${MONGO_SCHEMA} &>> $LOGFILE
stat $?


echo -n "Extracting the $COMPONENT"
cd /tmp
unzip -o ${COMPONENT}.zip &>> $LOGFILE
stat $?

echo "Injecting the $COMPONENT schema"
cd /tmp/mongodb-main
mongo < catalogue.js &>> $LOGFILE
mongo < users.js &>> $LOGFILE
stat $?





#sudo bash wrapper.sh mongodb