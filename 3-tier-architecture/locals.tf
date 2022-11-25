locals {
  user_data    = <<-EOT
#!/bin/bash
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo '<?php phpinfo(); ?>' > /var/www/html/phpinfo.php
sudo yum install php-mbstring php-xml -y
sudo systemctl restart httpd
sudo systemctl restart php-fpm
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
echo '<?php phpinfo(); ?>' > /var/www/html/phpinfo.php
cd phpMyAdmin
mv config.sample.inc.php config.inc.php
sed -i 's/localhost/${module.ec2-db.instance_ip_addr}/g' config.inc.php
  EOT
  db_user_data = <<-EOT
#!/bin/bash
sudo yum update -y
sudo yum install mariadb-server -y
sudo systemctl enable mariadb
sudo systemctl start mariadb
  EOT
}