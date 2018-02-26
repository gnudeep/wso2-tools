#!/bin/bash

CREATE_AM_DBS=true
CREATE_AA_DBS=true

#https://docs.wso2.com/display/AM210/Installing+and+Configuring+the+Databases

#DB admin credentials
DB_ADMIN_USER=root
DB_ADMIN_PASSWD=root@mysql
DB_HOST=localhost

#User management DB info
UM_DB=usermgt_db
UM_USER=usermgt_user
UM_USER_NET='%'
UM_PASSWD=passwdmysql
UM_SCHEMA=usermgt_mysql_5.1.73.sql

#Registry DB info
REG_DB=reg_db
REG_USER=reg_user
REG_USER_NET='%'
REG_PASSWD=passwdmysql
REG_SCHEMA=registry_mysql_5.1.73.sql

#AM DB info
AM_DB=am_db
AM_USER=am_user
AM_USER_NET='%'
AM_PASSWD=passwdmysql
AM_SCHEMA=apim_mysql_5.1.73.sql

#note that you do not need to run the database scripts against the created databases as the tables for the datasources
# are created at runtime.

#WSO2AM_STATS_DB
AMS_DB=ams_db
AMS_USER=ams_user
AMS_USER_NET='%'
AMS_PASSWD=passwdmysql

#WSO2_ANALYTICS_EVENT_STORE_DB
AAE_DB=ame_db
AAE_USER=aae_user
AAE_USER_NET='%'
AAE_PASSWD=passwdmysql

#WSO2_ANALYTICS_PROCESSED_DATA_STORE_DB
AAP_DB=amp_db
AAP_USER=aap_user
AAP_USER_NET='%'
AAP_PASSWD=passwdmysql

#GEO_LOCATION_DATA
AAG_DB=amg_db
AAG_USER=aag_user
AAG_USER_NET='%'
AAG_PASSWD=passwdmysql

#create db
#create_database <DB_ADMIN_USER> <DB_ADMIN_PASSWD> <DB_HOST> <DB_NAME>
create_database(){
    create_schema="mysql -u$1 -p$2 -h$3 -e 'CREATE DATABASE $4'"
    if eval ${create_schema}; then
        echo $?
        echo "$4 db created."
    else
        echo $?
        echo "$4 db creation failed."
    fi
}

#create schema
#create_schema <DB_ADMIN_USER> <DB_ADMIN_PASSWD> <DB_HOST> <DB_NAME> <DB_SCHEMA>
create_schema(){
    create_schema="mysql -u$1 -p$2 -h$3 $4 < $5"
    echo ${create_schema}
    if eval ${create_schema}; then
        echo $?
        echo "$4 schema created."
    else
        echo "$4 schema creation failed"
    fi
}

#create db user
#create_user <DB_ADMIN_USER> <DB_ADMIN_PASSWD> <DB_HOST> <DB_USER_NAME> <DB_USER_HOST> <DB_USER_PASSWD>
create_user(){
    `mysql -u$1 -p$2 -h$3 -e "CREATE USER '$4'@'%'"`
    if (($? == 0)); then
        echo $?
        echo "$4 user created."
        `mysql -u$1 -p$2 -h$3 -e "SET PASSWORD FOR '$4'@'$5' = PASSWORD('$6')"`
        echo $?
        if (($? == 0)); then
            echo "$4 user password updated"
        else
            echo "$4 user password update failed"
        fi
else
    echo $?
    echo "$4 user creation failed."
fi
}

#grant permission
#grant_permission <DB_ADMIN_USER> <DB_ADMIN_PASSWD> <DB_HOST> <DB_USER_NAME> <DB_USER_HOST> <DB_NAME>
grant_permission(){

    `mysql -u$1 -p$2 -h$3 -e "GRANT ALL ON $6.* TO '$4'@'$5'"`
    if (($? == 0)); then
        echo "Grant permission for user $4 on DB $6 successful"
        echo $?
    else
        echo "Grant permission for user $4 on DB $6 failed"
        echo $?
    fi
}

#-----------------------------------------------------------

#start
if [ ${CREATE_AM_DBS}=~"yes" ]; then
    if [ -f $UM_SCHEMA ]; then
        echo "Creating user management schema"
        create_database $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $UM_DB
        create_schema $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $UM_DB $UM_SCHEMA
        create_user $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $UM_USER $UM_USER_NET $UM_PASSWD
        grant_permission $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $UM_USER $UM_USER_NET $UM_DB
    else
        echo "User DB schema is not available"
    fi

    if [ -f $REG_SCHEMA ]; then
        echo "Creating Registry schema"
        create_database $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $REG_DB
        create_schema $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $REG_DB $REG_SCHEMA
        create_user $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $REG_USER $REG_USER_NET $REG_PASSWD
        grant_permission $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $REG_USER $REG_USER_NET $REG_DB
    else
        echo "Registry DB schema is not available"
    fi

    if [ -f $AM_SCHEMA ]; then
        echo "Creating API Manager schema"
        create_database $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AM_DB
        create_schema $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AM_DB $AM_SCHEMA
        create_user $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AM_USER $AM_USER_NET $AM_PASSWD
        grant_permission $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AM_USER $AM_USER_NET $AM_DB
    else
        echo "API Manager DB schema is not available"
    fi
fi

if [ ${CREATE_AA_DBS}=~"yes" ]; then

    if [ ${AMS_DB} ]; then
        echo "Creating API Manager Analytics stat DB"
        create_database $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AMS_DB
        create_user $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AMS_USER $AMS_USER_NET $AMS_PASSWD
        grant_permission $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AMS_USER $AMS_USER_NET $AMS_DB
    else
        echo "API Manager stat DB name is not defined"
    fi

    if [ ${AAE_DB} ]; then
        echo "Creating API Analytics event store DB"
        create_database $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AAE_DB
        create_user $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AAE_USER $AAE_USER_NET $AAE_PASSWD
        grant_permission $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AMS_USER $AAE_USER_NET $AAE_DB
    else
        echo "API Analytics event store DB name is not defined"
    fi

    if [ ${AAP_DB} ]; then
        echo "Creating API Analytics processed data store DB"
        create_database $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AAP_DB
        create_user $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AAP_USER $AAP_USER_NET $AAP_PASSWD
        grant_permission $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AMS_USER $AAP_USER_NET $AAP_DB
    else
        echo "API Analytics processed data store DB name is not defined"
    fi

    if [ ${AAG_DB} ]; then
        echo "Creating API Analytics Geo location data store DB"
        create_database $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AAG_DB
        create_user $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AAG_USER $AAG_USER_NET $AAG_PASSWD
        grant_permission $DB_ADMIN_USER $DB_ADMIN_PASSWD $DB_HOST $AAG_USER $AAG_USER_NET $AAG_DB
    else
        echo "API Manager GEO location DB name is not available"
    fi
fi
