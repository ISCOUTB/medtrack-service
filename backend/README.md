# Backend - MedTrack Service

Microservicio en Node.js + Express para gestionar medicamentos y tomas programadas.

## 📦 Instalación
```bash
npm install
```

## 🚀 Ejecución
```bash
npm run dev
```

## 🗄️ Base de datos
- PostgreSQL
- Variables de entorno en `.env`:
    - DB_HOST
    - DB_USER
    - DB_PASS
    - DB_NAME

## 🔗 Endpoints principales
- POST /medicamentos
- GET /medicamentos
- POST /tomas
- PUT /tomas/{id}/registrar
- GET /tomas/proximas
