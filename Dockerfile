# syntax=docker/dockerfile:1

########################
# Base de dependencias #
########################
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
# Cachea el directorio de npm para acelerar instalaciones
RUN --mount=type=cache,target=/root/.npm npm ci

#############
# Desarrollo#
#############
FROM node:20-alpine AS dev
WORKDIR /app
ENV NODE_ENV=development
# Copiamos node_modules preinstalados
COPY --from=deps /app/node_modules ./node_modules
# Copiamos el resto del código
COPY . .
# Expón el puerto interno del contenedor
EXPOSE 3000
# Comando por defecto en dev (hot reload con nodemon)
CMD ["npm", "run", "dev"]

############
# Producción
############
FROM node:20-alpine AS prod
WORKDIR /app
ENV NODE_ENV=production
# Copiamos solo los manifests e instalamos solo prod deps
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev
# Copiamos el código (sin dev files gracias al .dockerignore)
COPY . .
EXPOSE 3000
# Arranque en prod
CMD ["node", "server.js"]
