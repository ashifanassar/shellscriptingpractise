#!/bin/bash

#This is the file which is going to have all the common patterns



ID=$(id -u)
if [ $ID -ne 0 ] ; then
    echo -e "Not the root user"
    exit 1
fi

stat() {
    #this would check if the above executed command is pass or failure
    if [ $1 -eq 0 ] ; then #$? this would help us to understand if the above executed code is pass or fail
    echo -e "Success"
else
    echo -e "failure"
fi
}


#Declaring the Nodejs function

NODEJS() {
echo -e "Disabling the default nodejs"
dnf module disable nodejs -y &>> $LOGFILE
stat $?

echo -e "enabling the nodejs18"
dnf module enable nodejs:18 -y &>> $LOGFILE
stat $?

echo -e "Install nodejs:18"
dnf install nodejs -y &>> $LOGFILE
stat $?

CREATE_USER

DOWNLOAD_AND_EXTRACT


echo -e "Generating the artifacts"
cd $APPUSER_DIR
npm install &>> $LOGFILE
stat $?


START_SVC

}

#Creating user funtion
CREATE_USER() {
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
}


DOWNLOAD_AND_EXTRACT() {
echo -e "Downloading the $COMPONENT component:"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -e "Performing $COMPONENT cleanup"
rm -rf ${APPUSER_DIR}  &>> $LOGFILE
stat $?


echo -e "Extracting $APPUSER"
cd /home/roboshop
unzip -o /tmp/${COMPONENT}.zip   &>> $LOGFILE
stat $?
}

CONFIG_SVC() {
    echo -n "Configuring Permissions :"
    chown -R ${APPUSER}:${APPUSER} ${APPUSER_DIR}      &>>  $LOGFILE
    stat $? 

    echo -n "Configuring $COMPONENT Service: "
    sed -i -e 's/AMQPHOST/payment.roboshopshopping/' -e 's/AMQPHOST/rabbitmq.roboshopshopping/' -e 's/USERHOST/user.roboshopshopping/' -e 's/CARTHOST/cart.roboshopshopping/' -e 's/DBHOST/mysql.roboshopshopping/' -e 's/CARTENDPOINT/cart.roboshopshopping/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshopshopping/' -e 's/MONGO_ENDPOINT/mongodb.roboshopshopping/' -e 's/REDIS_ENDPOINT/redis.roboshopshopping/' -e 's/MONGO_DNSNAME/mongodb.roboshopshopping/' ${APPUSER_DIR}/systemd.service
    mv ${APPUSER_DIR}/systemd.service   /etc/systemd/system/${COMPONENT}.service
    stat $? 
}

START_SVC() {
echo -e "Starting the service"
systemctl eable $COMPONENT   &>> $LOGFILE
systemctl restart $COMPONENT  &>> $LOGFILE
stat $?
}