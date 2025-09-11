#!/bin/bash

# ===============================
# Script para instalar LAMP + WordPress en Kali Linux
# ===============================

# Configuración (modifica según tus necesidades)
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="CAMBIA_ESTO_POR_UNA_PASSWORD_SEGURA"
WP_USER="admin"
WP_PASS="CAMBIA_ESTO_POR_UNA_PASSWORD_SEGURA"
WP_DIR="/var/www/html"

# -------------------------------
# Paso 1: Actualizar sistema
# -------------------------------
echo "[*] Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# -------------------------------
# Paso 2: Parar servicios antiguos
# -------------------------------
echo "[*] Deteniendo servicios antiguos..."
sudo systemctl stop apache2
sudo systemctl stop mariadb

# -------------------------------
# Paso 3: Desinstalar Apache, MySQL y PHP
# -------------------------------
echo "[*] Desinstalando Apache, MySQL y PHP..."
sudo apt purge apache2* mariadb-server mariadb-client php* -y
sudo apt autoremove -y
sudo apt autoclean -y

# -------------------------------
# Paso 4: Eliminar archivos residuales
# -------------------------------
echo "[*] Eliminando archivos residuales..."
sudo rm -rf /etc/apache2 /etc/mysql /var/www/html/* /var/lib/mysql

# -------------------------------
# Paso 5: Instalar Apache, MySQL y PHP
# -------------------------------
echo "[*] Instalando Apache, MySQL y PHP..."
sudo apt install apache2 mariadb-server mariadb-client php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip libapache2-mod-php wget unzip -y

# -------------------------------
# Paso 6: Iniciar servicios
# -------------------------------
echo "[*] Iniciando servicios..."
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl start mariadb
sudo systemctl enable mariadb

# -------------------------------
# Paso 7: Configurar MySQL
# -------------------------------
echo "[*] Configurando base de datos..."
sudo mysql -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# -------------------------------
# Paso 8: Descargar WordPress
# -------------------------------
echo "[*] Descargando WordPress..."
cd $WP_DIR
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress/* .
sudo rm -r wordpress latest.tar.gz

# -------------------------------
# Paso 9: Configurar WordPress
# -------------------------------
echo "[*] Configurando WordPress..."
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASS/" wp-config.php

# -------------------------------
# Paso 10: Ajustar permisos
# -------------------------------
echo "[*] Ajustando permisos..."
sudo chown -R www-data:www-data $WP_DIR
sudo chmod -R 755 $WP_DIR

# -------------------------------
# Paso 11: Activar mod_rewrite
# -------------------------------
echo "[*] Activando mod_rewrite de Apache..."
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "[✅] Instalación completada. Abre http://localhost en tu navegador para terminar la configuración de WordPress."
