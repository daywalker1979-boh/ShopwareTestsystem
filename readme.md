# Shopware Staging-/Testsystem Creation Script
for ssh-use only

# What does it do
The script will copy a live shopware installation into a subdirectory called "staging", clones the database edits the theme.
A stagging-/test environment can be used for testing and development purposes. 

# Installation
Copy the .sh file into your shopware installation root. (ex. /var/www/vhosts/domain/httpdocs)
Edit the config.php and clone the database-part, to create a new one called "staging-db" and the settings to "staging-*".
Example
```php
return [
   'db' => [
       'username' => 'live-user',
       'password' => 'live-password',
       'dbname' => 'live-db',
       'host' => 'ilve-host',
       'port' => '3306'
   ],
   'staging-db' => [
       'staging-username' => 'staging-user',
       'staging-password' => 'staging-password',
       'staging-dbname' => 'staging-db',
       'staging-host' => 'staging-host',
       'port' => '3306'
   ],
];
```


# Shopware Staging-/Testsystem erstellungs-Script
nur für SSH

# Was macht dieses Script
Die Script kopiert eine Live-Shopware Installation in das Unterverzeichniss "staging", kopiert die Datenbank in eine Testdatenbank und verändert den Theme.
Diese Testumgebung eignet sich dann hervorragend um Updates oder Konfigurationen zu testen.

# Installation
Die .sh Datei in das Shopware-Root-Verzeichniss kopieren (z.B. /var/www/vhosts/domain/httpdocs)
Die config.php editieren und den Abschnitt "db" kopieren und wie folgt verändern:
```php
return [
   'db' => [
       'username' => 'live-user',
       'password' => 'live-password',
       'dbname' => 'live-db',
       'host' => 'ilve-host',
       'port' => '3306'
   ],
   'staging-db' => [
       'staging-username' => 'staging-user',
       'staging-password' => 'staging-password',
       'staging-dbname' => 'staging-db',
       'staging-host' => 'staging-host',
       'port' => '3306'
   ],
];
```
