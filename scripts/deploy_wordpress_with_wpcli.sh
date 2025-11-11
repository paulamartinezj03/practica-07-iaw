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
#Creamos archivo wp_config
wp config create \
  --dbname=$DB_NAME \
  --dbuser=$DB_USER \
  --dbpass=$DB_PASSWORD \
  --dbhost=localhost \
  --path=/var/www/html \
  --allow-root
  #Instalamos wordpress
  wp core install \
  --url=wordpressiaw6.myddns.me \
  --title=$WORDPRESS_TITLE \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASSWORD \
  --admin_email=$WORDPRESS_ADMIN_EMAIL \
  --path=/var/www/html \
  --allow-root  
#Configuramos los enlaces permanentes
wp rewrite structure '/%postname%/' \
  --path=/var/www/html \
  --allow-root
#Instalar plugin
wp plugin install wps-hide-login --activate \
    -path=/var/www/html \
    --allow-root
#Configuramos la url personalizada para el login
wp option update whl_page $URL_HIDE_LOGIN --path=/var/www/html --allow-root
#Modificamos el propietario y el grupo de /var/www/html a www-data
chown -R www-data:www-data /var/www/html