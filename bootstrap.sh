#!/bin/bash
apt-get update
apt-get -y upgrade

# openjdk installieren
apt-get install --no-install-recommends -y openjdk-7-jdk openjdk-7-jre-headless

# mariadb installieren
export DEBIAN_FRONTEND=noninteractive
MYSQL_PASS=geheim
debconf-set-selections <<< "mariadb-server-10.0 mysql-server/root_password password $MYSQL_PASS"
debconf-set-selections <<< "mariadb-server-10.0 mysql-server/root_password_again password $MYSQL_PASS"

apt-get install -y --allow-unauthenticated mariadb-server mariadb-client

# nginx
apt-get install -y nginx

# jruby installieren
JRUBY_VERSION=9.0.1.0
wget -q https://s3.amazonaws.com/jruby.org/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz -P /tmp/
tar -xf /tmp/jruby-bin-$JRUBY_VERSION.tar.gz -C /opt/

cp /vagrant/bootstrap/jruby.sh /etc/profile.d/
source /etc/profile.d/jruby.sh # achtung, jruby-version hier auch anpassen

chown vagrant:vagrant /opt/jruby-$JRUBY_VERSION/ -R

# pakete installieren
jruby -S gem install bundler

# webseite holen
mkdir -p /var/www/holarse
chown vagrant:vagrant /var/www/holarse
wget -q https://github.com/Holarse-Linuxgaming/website/archive/master.zip -P /tmp
unzip /tmp/master.zip -d /var/www/holarse

# installieren
cd /var/www/holarse/website-master
chown vagrant:vagrant /var/www/holarse/website-master -R
su vagrant -c '/opt/jruby-9.0.1.0/bin/jruby -S bundle install'
su vagrant -c '/opt/jruby-9.0.1.0/bin/jruby -S rake db:setup'

# systemd
cp /vagrant/holarse-www.service /lib/systemd/system/holarse-www.service
systemctl daemon-reload
systemctl enable holarse-www
systemctl start holarse-www

