#!/bin/bash
# Este script aplica un snapshot de esquema a la base de datos de Directus.

# El nombre del archivo se puede pasar como primer argumento, o se usa 'schema.yaml' por defecto.
FILENAME=${1:-schema.yaml}
INPUT_PATH="/directus/uploads/$FILENAME"

echo "Aplicando snapshot desde .$INPUT_PATH..."

# Comprobar si el archivo existe dentro del contenedor
docker exec directus-directus-1 test -f "$INPUT_PATH"
if [ $? -ne 0 ]; then
    echo "❌ Error: El archivo snapshot '$FILENAME' no se encuentra en directus/uploads/."
    exit 1
fi

# El --yes salta la confirmación manual
docker exec directus-directus-1 npx directus schema apply --yes "$INPUT_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Snapshot aplicado con éxito."
else
    echo "❌ Error al aplicar el snapshot."
fi
