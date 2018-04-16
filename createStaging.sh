#!/bin/bash

## Copyright antony Systemhaus GmbH (Dennis Scheidner)
## Version 1.0 - 04.04.2018

shopwareDir=$1
mysqlCommands=/tmp/mysqlcommands.sql

if [ -z $shopwareDir ]
        then
                echo "Bitte das Verzeichniss der Shopwareinstallation als Parameter übergeben"
                exit
fi

if [ ! -d $shopwareDir ]
        then
                echo "Das eingebene Verzeichniss existiert nicht!"
                exit
fi

if [ ! -e "${shopwareDir}/shopware.php" ]
        then
                echo "Kann in dem Verzeichniss ${shopwareDir} keine Shopwareinstallation finden"
                exit
fi

orgDbUser=$(cat ${shopwareDir}/config.php |grep \'username\' |sed -n "s/^.*'\(.*\)'.*$/\1/p")
orgDbPass=$(cat ${shopwareDir}/config.php |grep \'password\' |sed -n "s/^.*'\(.*\)'.*$/\1/p")
orgDbName=$(cat ${shopwareDir}/config.php |grep \'dbname\' |sed -n "s/^.*'\(.*\)'.*$/\1/p")
orgDbHost=$(cat ${shopwareDir}/config.php |grep \'host\' |sed -n "s/^.*'\(.*\)'.*$/\1/p")

stagingDbUser=$(cat ${shopwareDir}/config.php |grep \'staging-username\' |sed -n "s/^.*'\(.*\)'.*$/\1/p")
stagingDbPass=$(cat ${shopwareDir}/config.php |grep \'staging-password\' |sed -n "s/^.*'\(.*\)'.*$/\1/p")
stagingDbName=$(cat ${shopwareDir}/config.php |grep \'staging-dbname\' |sed -n "s/^.*'\(.*\)'.*$/\1/p")
stagingDbHost=$(cat ${shopwareDir}/config.php |grep \'staging-host\' |sed -n "s/^.*'\(.*\)'.*$/\1/p")
if [ -z $orgDbUser ] || [ -z $orgDbPass ] || [ -z $orgDbName ] || [ -z $orgDbHost ] || [ -z $stagingDbUser ] || [ -z $stagingDbPass ] || [ -z $stagingDbName ] || [ -z $stagingDbHost ];
        then
                echo "Kann die Datenbankzugangsdaten zum Live-System oder Staging-System nicht finden"
				echo "Wurde der Block staging-db in die Config eingefügt?"
                exit
fi

if [ -e $mysqlCommands ]
        then
                rm $mysqlCommands
fi




#Alte Staging umbenennen
oldName="${shopwareDir}/staging"
newName="${shopwareDir}/staging-$(date +"%d-%m-%y")"
echo "Rename ${oldName} to ${newName}"
mv ${oldName} ${newName}

#Neuen Staging Ordner anlegen
echo "Create folder ${oldName}"
mkdir $oldName

#Staging Datenbank löschen
echo "Delete staging database"
#TODO

#Datenbank kopieren
echo "Cloning database '${orgDbName}' on host '${orgDbHost}' to database '${stagingDbName}' on host '${stagingDbHost}'"
mysqldump --routines --single-transaction --triggers -u ${orgDbUser} --password=${orgDbPass} -h ${orgDbHost} ${orgDbName} | mysql -u ${stagingDbUser} --password=${stagingDbPass} -h ${stagingDbHost} ${stagingDbName}"

#Dateien kopieren
echo "Copy files"
cd ${shopwareDir}
find . -type f -not -path './staging*/*' -not -path './var/cache/*' -not -path './files/*' -exec cp -v --parents '{}' '${oldName}' \;

#Config Anpassen
echo "Edit staging config.php"
mv ${oldName}/config.php  ${oldName}/config.php.org
cat  ${oldName}/config.php.org |sed "s/\('db'\)/'db-live'/g" |sed "s/\('staging-\)/'/g" > ${oldName}/config.php

#Bare Template Anpassen
echo "Edit bare template"
mv ${oldName}/themes/Frontend/Bare/frontend/index/index.tpl ${oldName}/themes/Frontend/Bare/frontend/index/index.tpl.old
commandstr="cat ${oldName}/themes/Frontend/Bare/frontend/index/index.tpl.old |sed \"s/{block name='frontend_index_after_body'}{\/block}/{block name='frontend_index_after_body'}<div style=\\\"width: 100%; background-color: #ff0000;\\\" cl
ass=\\\"staging\\\"><h1 style=\\\"font-size: 24px; color: #ffffff;\\\">STAGING SYSTEM<\\\/h1><\\\/div>{\\\/block}/g\" > ${oldName}/themes/Frontend/Bare/frontend/index/index.tpl"
eval $commandstr
mv ${oldName}/themes/Backend/ExtJs/backend/index/header.tpl ${oldName}/themes/Backend/ExtJs/backend/index/header.tpl.old
commandstr="cat ${oldName}/themes/Backend/ExtJs/backend/index/header.tpl.old |sed \"s/{block name='backend\/base\/header\/title'}Shopware /{block name='backend\/base\/header\/title'}STAGING Shopware /g\" > ${oldName}/themes/Backend/ExtJs
/backend/index/header.tpl"
eval $commandstr

#Datenbank anpassen
echo "Edit staging database settings"
echo "UPDATE s_core_shops SET base_path = '/staging' WHERE main_id is NULL AND \`default\` = '1' AND \`active\` = '1'" >> ${mysqlCommands}
echo "UPDATE s_core_config_values SET \`value\` = 'b:1;' WHERE element_id = '254' AND shop_id = '1'" >> ${mysqlCommands}
mysql -u ${stagingDbUser} --password=${stagingDbPass} -h ${stagingDbHost} -D ${stagingDbName} < ${mysqlCommands}


# Robot.txt erstellen
echo "Edit robots.txt for staging"
echo "User-agent: *" > ${oldName}/robots.txt
echo "Disallow: /" >> ${oldName}/robots.txt
