# Usar la imagen oficial de Directus como base
FROM directus/directus:latest

# Copiar nuestro package.json de extensiones a la carpeta correcta dentro de la imagen
COPY ./extensions/package.json /directus/extensions/

# Ejecutar npm install para instalar las dependencias de la extensión durante la construcción de la imagen
RUN cd /directus/extensions && npm install
