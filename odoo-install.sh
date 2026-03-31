# === Step to Install Odoo 16 on Ubuntu 22.04, Python 3.10.12 ===


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

# Add User (example: User is kokai)
sudo useradd -m -d /opt/kokai -U -r -s /bin/bash kokai


# === Setting PostgreSQL ===
# install PostgreSQL
sudo apt install postgresql -y
# create User (recommended)
sudo -u postgres createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt kokai # password need to be entered
sudo -u postgres psql -c "ALTER USER kokai WITH SUPERUSER";
# or 
# sudo su - postgres -c "createuser -s kokai"


# === Setup PGBouncer ===



# === Setup Virtual Env ===
# clone base addons
sudo su - kokai
git clone https://www.github.com/odoo/odoo --depth 1 --branch 16.0 kokai
# clone custom addons
mkdir kokai/kokai-addons
cd kokai/kokai-addons

cd ../..

# create venv
python3 -m venv kokai-venv
source kokai-venv/bin/activate

# Upgrade pip tools
pip install --upgrade pip setuptools wheel

# Instal python package requirements
pip install "Cython<3.0.0"
pip install "gevent==22.10.2"
pip install -r kokai/requirements.txt # maybe this command will error because version of gevent, recommended: delete line of gevent package
exit


# === Setup Configuration ===
# odoo config
sudo cp kokai/kokai-addons/config/odoo.conf /etc/kokai.conf # don't forget to adjust config
# service config
sudo cp kokai/kokai-addons/config/odoo.service /etc/systemd/system/kokai.service
# nginx config
sudo cp kokai/kokai-addons/nginx/nginx.conf /etc/nginx/sites-available/kokai
sudo ln -s /etc/nginx/sites-available/kokai /etc/nginx/sites-enabled/kokai
sudo nginx -t
sudo systemctl restart nginx


sudo systemctl daemon-reload
