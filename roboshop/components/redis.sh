
#!/bin/bash

source components/common.sh #source will keep all the functions

COMPONENT="redis"
LOGFILE="/tmp/$COMPONENT.log"
REDIS_REPO="https://rpms.remirepo.net/enterprise/remi-release-8.rpm"




echo -e "Installing $COMPONENT Repo"
dnf install $REDIS_REPO -y &>> $LOGFILE
stat $?

echo -e "Enabling $COMPONENT"
dnf module enable redis:remi-6.2 -y  &>>  $LOGFILE
stat $?

echo -e "Installing $COMPONENT"
dnf install redis -y &>> $LOGFILE
stat $?

echo -e "Enabling the $COMPONENT visibility"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
stat $?


echo -e "starting $COMPONENT"
systemctl enable $COMPONENT &>> $LOGFILE
systemctl restart $COMPONENT &>> $LOGFILE
stat $?

#sudo bash wrapper.sh redis