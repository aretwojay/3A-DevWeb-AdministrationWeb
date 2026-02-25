#!/bin/bash
# restore.sh - Restauration de la base PostgreSQL
# Usage : ./restore.sh ./backups/backup_XXXXXXXX_XXXXXX.sql.gz
set -euo pipefail
# ============================================
# CONFIGURATION - Adaptez ces valeurs
# ============================================
CONTAINER_NAME="db_container"
DB_NAME="postgres"
DB_USER="postgres"
# ============================================
# NE PAS MODIFIER EN DESSOUS
# ============================================
# Vérifier qu'un argument a été donné
if [ -z "${1:-}" ]; then
echo "Usage: ./restore.sh <fichier_backup.sql.gz>"
echo ""
echo "Backups disponibles :"
ls -lh ./backups/backup_*.sql.gz 2>/dev/null || echo " Aucun backup trouvé."
exit 1
fi
BACKUP_FILE="$1"
# Vérifier que le fichier existe
if [ ! -f "$BACKUP_FILE" ]; then
echo "ERREUR : Fichier '$BACKUP_FILE' introuvable"
exit 1
fi
# Demander confirmation
echo "==========================================="
echo " RESTAURATION DE BASE DE DONNÉES"
echo "==========================================="
echo "Fichier : $BACKUP_FILE"
echo "Base : $DB_NAME"
echo "Container: $CONTAINER_NAME"
echo "==========================================="
echo ""
echo "ATTENTION : La base '$DB_NAME' sera COMPLÈTEMENT ÉCRASÉE."
read -p "Continuer ? (oui/non) : " CONFIRM
if [ "$CONFIRM" != "oui" ]; then
echo "Restauration annulée."
exit 0
fi
# Restauration
echo ""
echo "[$(date)] Restauration en cours..."
echo "[$(date)] Suppression de la base existante..."
docker exec "$CONTAINER_NAME" dropdb -U "$DB_USER" --if-exists "$DB_NAME"
echo "[$(date)] Création d'une base vide..."
docker exec "$CONTAINER_NAME" createdb -U "$DB_USER" "$DB_NAME"
echo "[$(date)] Injection du dump..."
gunzip -c "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" "$DB_NAME"
echo ""
echo "[$(date)] Restauration terminée avec succès !"