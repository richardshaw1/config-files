#!/bin/bash
# Configure an Amazon Linux 2 instance for Wordpress

# PLEASE CHANGE THE FOLLOWING LINE TO MATCH YOUR INITIALS USED FOR ALL DEPLOYMENTS
INITS=mobilise-academy-rs

# install all available updated
yum update -y
# install apache web server and start it for the health checks to work
yum install -y httpd
systemctl start httpd.service

# enable php7.xx from amazon-linux-extra and install it
amazon-linux-extras enable php7.4
yum clean metadata
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel} git unzip

# install imagick extension for wordpress
yum -y install gcc ImageMagick ImageMagick-devel ImageMagick-perl
pecl channel-update pecl.php.net
printf "\n" | pecl install imagick
chmod 755 /usr/lib64/php/modules/imagick.so
cat <<EOF >>/etc/php.d/20-imagick.ini
extension=imagick
EOF

systemctl restart php-fpm.service

# Change OWNER and permission of directory /var/www
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Download wordpress package from GitHub and extract 
wget https://github.com/mobilise-academy/wordpress/archive/refs/heads/main.zip -O /tmp/wordpress.zip
cd /tmp
unzip /tmp/wordpress.zip
mv wordpress-main/* /var/www/html
sed -i "s/INITS/$INITS/" /var/www/html/wp-config.php
cd /var/www/html

# change permission of /var/www/html directory
chown -R ec2-user:apache /var/www/html

# enable .htaccess files in apache config using sed command

sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

# set apache web server service to auto-start and restart to load the latest configuration

systemctl enable httpd.service
systemctl restart httpd.service
