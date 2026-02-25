#!/bin/bash
# backup.sh - Sauvegarde de la base PostgreSQL
set -euo pipefail
# ============================================
# CONFIGURATION - Adaptez ces valeurs
# ============================================
CONTAINER_NAME="db_container"
DB_NAME="postgres"
DB_USER="postgres"
BACKUP_DIR="./backups"
RETENTION_DAYS=7
# ============================================
# NE PAS MODIFIER EN DESSOUS
# ============================================
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.sql.gz"
# Créer le dossier de backup
mkdir -p "$BACKUP_DIR"
# Dump de la base + compression
echo "[$(date)] Sauvegarde en cours..."
docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"
# Vérification
if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
echo "[$(date)] Sauvegarde réussie : $BACKUP_FILE"
echo "[$(date)] Taille : $(du -h "$BACKUP_FILE" | cut -f1)"
else
echo "[$(date)] ERREUR : La sauvegarde a échoué !"
exit 1
fi
# Rotation : supprimer les backups de plus de 7 jours
find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete
echo "[$(date)] Rotation effectuée (conservation : ${RETENTION_DAYS} jours)"