#!/bin/bash
set -ex

#Importamos el archivo .env
source .env

#Configuramos las respuestas de la instalación de phpmyadmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
#Actualizamos repositorios
apt update
#Instalación de phpmyadmin
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

#-----------------------------------------------------------------------------------
#Instalación de Adminer
mkdir -p /var/www/html/adminer

wget https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1-mysql.php -P /var/www/html/adminer
mv /var/www/html/adminer/adminer-5.4.1-mysql.php /var/www/html/adminer/index.php
#---------------------------------------------------------------------------------------------
#Creamos una base de datos de ejemplo
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root -e "CREATE DATABASE $DB_NAME";

#Creamos un usuario y contraseña para la base de datos
mysql -u root -e "DROP USER IF EXISTS '$DB_USER'@'%';";
mysql -u root -e "CREATE USER $DB_USER@'%' IDENTIFIED BY '$DB_PASSWORD'";
#Le asignamos privilegios de nuestra base de datos
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'%'";
#Actualizamos repositorios
sudo apt update
#Instalación de GoAccess
sudo apt install goaccess -y
#Comprobamos la versión
goaccess --version
#Creamos directorio 
sudo mkdir -p /var/www/html/stats
#Creación de un archivo HTML en tiempo real y en segundo plano
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize
#Creación de contraseña y usuario
sudo htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD
#Reiniciamos el apache
sudo systemctl restart apache2
#Copiamos conf 
cp ../conf/000-default-stats.conf /etc/apache2/sites-available/000-default.conf
#Copiamos el archivo .htaccess
cp ../htaccess/.htaccess /var/www/html/stats
#Reiniciamos el apache
sudo systemctl restart apache2