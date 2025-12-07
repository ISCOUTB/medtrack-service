# MedTrack Service 🏥

**MedTrack** es una solución integral para el seguimiento y control de la medicación personal. Consta de una aplicación móvil moderna y un servicio backend robusto.

## 📚 Documentación
La documentación completa de la arquitectura del sistema sigue el estándar **ARC42** y se encuentra disponible en:
👉 [Documentación de Arquitectura (ARC42)](docs/ARC42.md)

También puedes consultar:
- [Esquemas de Base de Datos](docs/sql/)
- [Diagramas de Arquitectura](docs/architecture-diagrams/)
- [Especificación API (OpenAPI)](docs/openapi.yaml)

## 🚀 Características Principales
- **Gestión de Medicamentos:** Registra nombre, dosis, frecuencia y notas.
- **Seguimiento de Tomas:** (En desarrollo) Registra cuándo tomas tus medicamentos.
- **Seguridad:** Autenticación segura y protección de datos.
- **Interfaz Moderna:** Diseño limpio y fácil de usar (Material Design 3).

## 🛠️ Tecnologías
### Backend
- **Runtime:** Node.js
- **Framework:** Express.js
- **Base de Datos:** PostgreSQL
- **Autenticación:** JWT (JSON Web Tokens)

### Frontend (Móvil)
- **Framework:** Flutter
- **Lenguaje:** Dart
- **Estado:** Provider
- **Estilo:** Material Design 3

## ⚙️ Instalación y Ejecución

### Prerrequisitos
- Docker y Docker Compose
- Node.js (v16+)
- Flutter SDK (v3.0+)

### Pasos Rápidos
1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/ISCOUTB/medtrack-service.git
   cd medtrack-service
   ```

2. **Iniciar Backend y Base de Datos:**
   ```bash
   cd backend
   # Iniciar base de datos
   docker-compose up -d
   # Instalar dependencias y correr servidor
   npm install
   npm start
   ```

3. **Iniciar Aplicación Móvil:**
   ```bash
   cd medtrack_app
   flutter pub get
   flutter run
   ```

## 📄 Licencia
Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.
