#!/bin/bash

COMPONENT="mysql"
LOGFILE="/tmp/$COMPONENT.log"
MYSQL_REPO= "https://raw.githubusercontent.com/stans-robot-project/$COMPONENT/main/$COMPONENT.repo"
SCHEMA_URL=""https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"

source components/common.sh #source will keep all the functions

echo -e -n "Disabling the older components of mysql"
dnf module diable mysql -y
stat $?

dnf install mysql-community-server -y

echo -e "configuring the repos"
curl -s -L -o /etc/yum.repos.d/mysql.repo $MYSQL_REPO &>>${LOGFILE}
stat $?

echo -e "Intall the mysql"
dnf install $COMPONENT  &>>${LOGFILE}
stat $?


echo -e "Start the mysql"
systemctl enable mysqld
systemctl start mysqld
stat $?


echo "Fetching $COMPONENT root password:"
DEFAULT_ROOT_PASS = $(grep "temporary password" /var.log.mysqld.log | awk -F " " '{print $NF}')
stat $?

echo "show databases;" | mysql -uroot -p${mysql_root_password} &>> $LOGFILE
if [$? -ne 0] ; then
    echo -n "changing the default root password:"
    echo "ALTER USER 'root@'localhost' IDENTIFIED BY 'Roboshop@1' | mysql --connect-exprired-password -uroot -p$DEFAULT_ROOT_PASS
    stat $?
fi

echo -n "Downloading and extracting $COMPONENT schema file:"
curl -s -L -o /tmp/mysql.zip $SCHEMA_URL &>> $LOGFILE
unzip -o /tmp/mysql.zip &>> $LOGFILE
stat $?

echo -n "Extract the $COMPONENT"
ls -ltr /home/centos/myzql.zip
unzip -o /home/centos/mysql.zip
ls -ltr /home/centos
stat $?

echo -n "injecting the schema:"
cd /tmp/${COMPONENT}-main/
mysql -u root -pRoboShop@1 <shipping.sql &>> $LOGFILE

#command to execute
#sudo bash wrapper.sh mysql Roboshop@1