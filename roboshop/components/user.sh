#!/bin/bash

source components/common.sh #source will keep all the functions


COMPONENT="user"
LOGFILE="/tmp/$COMPONENT.log"
APPUSER="roboshop"
APPUSER_DIR="/home/roboshop/${COMPONENT}"



#calling Nodejs funtion
NODEJS

#calling from common.sh to create the user
CREATE_USER


#downloading and extracting the component
DOWNLOAD_AND_EXTRACT


#Configuring the permissions

CONFIG_SVC

#starting the service
START_SVC

#sudo bash wrapper.sh user
