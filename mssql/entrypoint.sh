#!/bin/bash
set -euo pipefail

# Démarrer SQL Server en arrière-plan
/opt/mssql/bin/sqlservr &

# Fonction d'attente : attendre que sqlcmd puisse exécuter SELECT 1
echo "Waiting for SQL Server to be ready..."
until /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "SET NOCOUNT ON; SELECT 1" >/dev/null 2>&1; do
  echo "SQL Server not ready yet - sleeping 2s..."
  sleep 2
done
echo "SQL Server ready."

# Répertoire des scripts et répertoire pour marqueurs
SCRIPTS_DIR=/scripts
MARKER_DIR=/var/opt/mssql/init-markers
mkdir -p "$MARKER_DIR"

# Exécuter chaque script .sql si pas déjà marqué
for sql in "$SCRIPTS_DIR"/*.sql; do
  [ -e "$sql" ] || continue
  base=$(basename "$sql")
  marker="$MARKER_DIR/$base.done"

  if [ -f "$marker" ]; then
    echo "Skipping $base (already applied)"
    continue
  fi

  echo "Executing $base ..."
  if /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -i "$sql"; then
    echo "OK: $base"
    touch "$marker"
  else
    echo "ERROR executing $base" >&2
    # Ne pas laisser en silent fail — sortir pour diagnostiquer
    exit 1
  fi
done

# Garder le processus principal en avant-plan : attendre sqlservr
wait