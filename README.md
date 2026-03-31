# ODOO SETUP
This repository is step for install and setup Odoo 16 on Ubuntu 22.04 with Python 3.10.12

---

## You need to adjust file:
1. `config/nginx.conf` for configuration nginx, set port will be use for odoo
2. `config/odoo.conf` for odoo configuration
3. `config/odoo.service` for service configuration to run odoo
4. `config/pgbouncer.ini` for pgbouncer config if use pgbouncer for db connection
5. `config/userlist-for-pgbouncer.txt` for db user and password config
6. `requirements/additional_package.txt` for additional python package use in custom module
7. `odoo-install.sh` set variable user and password

After that, you are ready to run odoo-install.sh
