#!/bin/bash
sudo apt-get update
sudo apt-get -y upgrade

# openjdk installieren
sudo apt-get install --no-install-recommends -y openjdk-7-jdk openjdk-7-jre-headless

# mariadb installieren
export DEBIAN_FRONTEND=noninteractive
MYSQL_PASS=geheim
sudo debconf-set-selections <<< "mariadb-server-10.0 mysql-server/root_password password $MYSQL_PASS"
sudo debconf-set-selections <<< "mariadb-server-10.0 mysql-server/root_password_again password $MYSQL_PASS"

sudo apt-get install -y --allow-unauthenticated mariadb-server mariadb-client

# jruby installieren
JRUBY_VERSION=9.0.1.0
wget -q https://s3.amazonaws.com/jruby.org/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz -P /tmp/
sudo tar -xf /tmp/jruby-bin-$JRUBY_VERSION.tar.gz -C /opt/

sudo cp /vagrant/bootstrap/jruby.sh /etc/profile.d/
source /etc/profile.d/jruby.sh # achtung, jruby-version hier auch anpassen

sudo chown vagrant:vagrant /opt/jruby-$JRUBY_VERSION/ -R

# pakete installieren
jruby -S gem install bundler

# webseite holen
mkdir -p /var/www/holarse
sudo chown vagrant:vagrant /var/www/holarse
wget -q https://github.com/Holarse-Linuxgaming/website/archive/master.zip -P /tmp
unzip /tmp/master.zip -d /var/www/holarse
sudo chown vagrant:vagrant /var/www/holarse/website-master -R

# installieren
cd /var/www/holarse/website-master
jruby -S bundle install
jruby -S rake db:setup

nohup jruby -S rails s -b 0.0.0.0 &
