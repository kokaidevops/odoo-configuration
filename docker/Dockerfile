# Menggunakan base image Odoo 16 resmi
FROM odoo:16.0

USER root

# Update & Install system dependencies yang sering bikin error (OpenSSL, LibLDAP, dll)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    swig \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 1. Buat Virtual Environment untuk isolasi
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 2. Upgrade pip, setuptools, dan wheel ke versi terbaru
# Ini krusial untuk mengatasi masalah "setuptools" yang sering Anda alami
RUN pip3 install --upgrade pip setuptools wheel

# 3. Copy requirements_base.md
COPY requirements_base.md /etc/odoo/requirements_base.txt
RUN pip install --no-cache-dir -r /etc/odoo/requirements_base.txt

# 4. Copy requirements_custom.md
COPY requirements_custom.md /etc/odoo/requirements_custom.txt
RUN pip install --no-cache-dir -r /etc/odoo/requirements_custom.txt

RUN chown -R odoo:odoo /opt/ven

USER odoo
