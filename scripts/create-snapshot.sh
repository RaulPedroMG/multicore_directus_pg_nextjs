#!/bin/bash
# Este script crea un snapshot del esquema de Directus.

# El nombre del archivo se puede pasar como primer argumento, o se usa 'schema.yaml' por defecto.
FILENAME=${1:-schema.yaml}

# La carpeta de salida dentro del contenedor. Usamos /directus/uploads porque está mapeada a nuestra máquina local.
OUTPUT_PATH="/directus/uploads/$FILENAME"

echo "Creando snapshot en .$OUTPUT_PATH..."

docker exec directus-directus-1 npx directus schema snapshot --yes "$OUTPUT_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Snapshot creado con éxito en directus/uploads/$FILENAME"
else
    echo "❌ Error al crear el snapshot."
fi
