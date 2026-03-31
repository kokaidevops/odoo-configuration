#!/bin/bash

# --- KONFIGURASI ---
DB_NAME="db_name"
DB_USER="db_user"              # Sesuaikan dengan user database Odoo Anda
ODOO_USER="odoo_user"            # User Linux yang menjalankan Odoo
FILESTORE_PATH="/opt/$ODOO_USER/.local/share/Odoo/filestore/$DB_NAME" # Path default Odoo
BACKUP_DIR="/tmp/odoo_backup_temp"
DEST_DIR="./backups"        # Lokasi penyimpanan file ZIP akhir
DATE=$(date +%Y%m%d_%H%M%S)
FINAL_ZIP="backup_${DB_NAME}_${DATE}.zip"

# Membuat direktori kerja
mkdir -p $BACKUP_DIR
mkdir -p $DEST_DIR

echo "=== Memulai Proses Backup Odoo Native: $DB_NAME ==="

# 1. Cek Ukuran Database menggunakan pg_size_pretty
echo "1. Mengecek ukuran database..."
DB_SIZE=$(psql -U $DB_USER -d postgres -t -c "SELECT pg_size_pretty(pg_database_size('$DB_NAME'));")
echo "Ukuran Database aktif: $DB_SIZE"

# 2. Backup Database ke format .dump
echo "2. Mengekspor database..."
# Gunakan sudo jika user linux saat ini tidak punya akses langsung ke postgres
pg_dump -U $DB_USER -F c $DB_NAME > "$BACKUP_DIR/${DB_NAME}.dump"

# 3. Backup Folder Filestore
echo "3. Menyalin folder filestore..."
if [ -d "$FILESTORE_PATH" ]; then
    cp -r "$FILESTORE_PATH" "$BACKUP_DIR/filestore"
else
    echo "Peringatan: Folder filestore tidak ditemukan di $FILESTORE_PATH"
fi

# 4. Kompresi menjadi satu file ZIP
echo "4. Membuat file ZIP akhir..."
cd $BACKUP_DIR
zip -r "/opt/odoo/$DEST_DIR/$FINAL_ZIP" "${DB_NAME}.dump" "filestore"
cd ../..

# 5. Pembersihan
echo "5. Membersihkan file temporer..."
rm -rf $BACKUP_DIR

echo "--------------------------------------"
echo "BACKUP SELESAI!"
echo "Lokasi File: $DEST_DIR/$FINAL_ZIP"
echo "--------------------------------------"
