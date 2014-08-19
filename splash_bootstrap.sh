if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else
# Boostrap for software and configs common to all xRadar servers
## Written for Ubuntu 14.04
## To be run as root user on a new, untouched server

# Change root password to 'hpod ...'
## Enter at prompt
## TODO: change this to add pw w/o dialog
echo "hpod344odce" | passwd > /dev/null 2>&1

# Add repository for latest Git
sudo add-apt-repository -y ppa:git-core/ppa

# OS updates
sudo apt-get update
sudo apt-get -y upgrade

# Install software essential to all xRadar servers
sudo apt-get -y install git zlib1g-dev xvfb x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic build-essential joe htop python-dev python-pip qt4-dev-tools python-qt4reactor python-twisted openssl libssl-dev joe htop lynx

## Pip Packages for splash
pip install pillow requests psutil qt4reactor pyOpenSSL
## Set timezone with NTP
## Note: Do ntpdate update only once, before update
## Note: ntp update needs port 123
export TZ=UTC
sudo ntpdate pool.ntp.org
sudo apt-get -y install ntp
# Remove temporary dependencies
sudo apt-get -y autoremove

# Add 'splash' user
## Note: use the 'hpod' pw
## Note: in the future we probably do not want the xradar user having sudo rights
## TODO: change this to add pw w/o dialog

## Pull and extract and install splash 
cd /tmp
wget https://github.com/scrapinghub/splash/archive/1.0.tar.gz
gunzip 1.0.tar.gz
tar -xvf 1.0.tar
cd splash-1.0
python setup.py install

# Append to hosts for splash
echo "127.0.0.1  splash " >> /etc/hosts

echo "description 'splashd'
author 'software@coenterprise.com'

start on runlevel [2345]
stop on runlevel [!2345]

respawn
respawn limit 10 5
setuid root
setgid root

exec nohup xvfb-run python -m splash.server 1>&2 &>/var/log/bookradar/splash.log 1>&2 &>/var/log/bookradar/splash.log&" >> /etc/init/splashd.conf
# start splash server
service splashd start
sleep 5
echo "Cleaning up install"
rm -rf /tmp/*
fi