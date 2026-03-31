#!/bin/bash

# VARIABLE
USER="kokai"
PASSWORD="password"


# ===============================================================================
# ========= STEP TO INSTALL ODOO 16 ON UBUNTU 22.04 WITH PYTHON 3.10.12 =========
# ===============================================================================

# Update & Upgrade System Operation
sudo apt update && sudo apt upgrade -y
# Install Dependencies
sudo apt install -y python3-dev python3-venv python3-pip libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev nodejs npm git

# Install Xfonts
sudo apt install -y xfonts-75dpi

# Install Wkhtmltox (example we set to install version of 0.12.6.1-3)
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo dpkg -i wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo apt install -f

# Add User
sudo useradd -m -d /opt/$USER -U -r -s /bin/bash $USER


# === Setting PostgreSQL ===
# install PostgreSQL
sudo apt install postgresql -y
# create User (recommended)
sudo -u postgres createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt $USER # password need to be entered
sudo -u postgres psql -c "ALTER USER $USER WITH SUPERUSER";
# or 
# sudo su - postgres -c "createuser -s $USER"


# === Setup PgBouncer ===
# check password postgres or user
# sudo -u postgres psql -t -A -c "SELECT concat('\"', usename, '\" \"', passwd, '\"') FROM pg_shadow WHERE usename = '$USER';"

# install PgBouncer
sudo apt install pgbouncer -y
# set config
sudo cp config/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini
# set user list for pgbouncer
sudo cp config/userlist-for-pgbouncer.txt /etc/pgbouncer/userlist.txt
# set access permission
sudo chown pgbouncer:pgbouncer /etc/pgbouncer/userlist.txt
sudo chmod 600 /etc/pgbouncer/userlist.txt
# run pgbouncer
sudo systemctl enable pgbouncer
sudo systemctl restart pgbouncer


# === Setup Virtual Env ===
# clone base addons
sudo su - $USER
git clone https://www.github.com/odoo/odoo --depth 1 --branch 16.0 $USER
# clone custom addons
mkdir $USER/$USER-addons
cd $USER/$USER-addons

cd ../..

# create venv
python3 -m venv $USER-venv
source $USER-venv/bin/activate

# Upgrade pip tools
pip install --upgrade pip setuptools wheel

# Instal python package requirements
pip install "Cython<3.0.0"
pip install "gevent==22.10.2"
pip install requirements/base_package.txt
#or pip install -r $USER/requirements.txt # maybe this command will error because version of gevent, recommended: delete line of gevent package
exit


# === Setup Configuration ===
# odoo config
sudo cp config/odoo.conf /etc/$USER.conf # don't forget to adjust config
# service config
sudo cp config/odoo.service /etc/systemd/system/$USER.service
# nginx config
sudo cp config/nginx.conf /etc/nginx/sites-available/$USER
sudo ln -s /etc/nginx/sites-available/$USER /etc/nginx/sites-enabled/$USER
sudo nginx -t
sudo systemctl restart nginx


sudo systemctl daemon-reload
