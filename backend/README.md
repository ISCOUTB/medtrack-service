# MedTrack Backend API

Este es el servicio backend para MedTrack, construido con Node.js, Express y PostgreSQL.

## 📋 Requisitos
- Node.js (v16 o superior)
- Docker y Docker Compose (para la base de datos)

## 🚀 Configuración y Ejecución

### 1. Variables de Entorno
Copia el archivo `.env.example` a `.env`:
```bash
cp .env.example .env
```
Asegúrate de que las credenciales de base de datos coincidan con las de `docker-compose.yml`.

### 2. Base de Datos
Inicia el contenedor de PostgreSQL:
```bash
docker-compose up -d
```
Esto levantará una instancia de PostgreSQL en el puerto 5432.

### 3. Instalar Dependencias
```bash
npm install
```

### 4. Ejecutar Servidor
Para desarrollo (con hot-reload si tienes nodemon):
```bash
npm start
```
El servidor correrá en `http://localhost:3000`.

## 📚 Documentación API
La documentación de la API está disponible vía Swagger UI una vez que el servidor está corriendo:
👉 [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

Para más detalles sobre la arquitectura, consulta el [README principal](../README.md).

## 🧪 Tests
Para ejecutar los scripts de prueba de base de datos:
```bash
npm run test-db
```
