#!/bin/bash
set -ex
#Importamos las variables de entorno 
source .env
#Eliminamos descargas previas de WP-CLI
 rm -f /tmp/wp-cli.phar
 #Descargamos WP-CLI
 wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp
 #Le asignamos permisos de ejecución
 chmod +x /tmp/wp-cli.phar
 #Movemos wp-cli.phar a /usr/local/bin/wp
 mv /tmp/wp-cli.phar /usr/local/bin/wp
 #Eliminamos instalaciones previas
 rm -rf /var/www/html/*
 #Instalamos wp core
wp core download \
  --locale=es_ES \
  --path=/var/www/html \
  --allow-root
  #Creamos una base de datos de ejemplo
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root -e "CREATE DATABASE $DB_NAME";

#Creamos un usuario y contraseña para la base de datos
mysql -u root -e "DROP USER IF EXISTS '$DB_USER'@'$IP_CLIENTE_MYSQL';";
mysql -u root -e "CREATE USER $DB_USER@'$IP_CLIENTE_MYSQL' IDENTIFIED BY '$DB_PASSWORD'";
#Le asignamos privilegios de nuestra base de datos
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'$IP_CLIENTE_MYSQL'";
#Creamos el archivo deconfiguracion de wordpress
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
#Configuramos las variables del archivo php
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/wp-config.php
  #Modificamos el propietario y el grupo de /var/www/html a www-data
  chown -R www-data:www-data /var/www/html