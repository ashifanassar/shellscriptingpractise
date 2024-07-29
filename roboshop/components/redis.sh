
#!/bin/bash

ID=$(id -u)
if [ $ID -ne 0 ] ; then
    echo -e "Not the root user"
    exit 1
fi

COMPONENT="redis"
LOGFILE="/tmp/$COMPONENT.log"
REDIS_REPO="https://rpms.remirepo.net/enterprise/remi-release-8.rpm"

stat() {
    #this would check if the above executed command is pass or failure
    if [ $1 -eq 0 ] ; then #$? this would help us to understand if the above executed code is pass or fail
    echo -e "Success"
else
    echo -e "failure"
    fi
}



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
stat $?


echo -e "starting $COMPONENT"
systemctl enable $COMPONENT &>> $LOGFILE
systemctl restart $COMPONENT &>> $LOGFILE
stat $?