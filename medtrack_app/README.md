# MedTrack App Móvil

Aplicación móvil desarrollada en Flutter para el servicio MedTrack.

## 📱 Características
- **Inicio de Sesión y Registro:** Gestión de usuarios segura.
- **Mis Medicamentos:** Lista visual de medicamentos con dosis y frecuencia.
- **Agregar Medicamento:** Formulario sencillo para registrar nuevos tratamientos.
- **Material Design 3:** Interfaz moderna y adaptable.

## 🛠️ Requisitos
- Flutter SDK (v3.0 o superior)
- Emulador Android/iOS o dispositivo físico.
- Backend de MedTrack corriendo localmente (para desarrollo).

## 🚀 Ejecución

### 1. Obtener dependencias
```bash
flutter pub get
```

### 2. Ejecutar
```bash
flutter run
```

> **Nota para Emulador Android:** La app está configurada para conectarse a `http://10.0.2.2:3000` por defecto, que es la dirección del host desde el emulador Android.

## 📁 Estructura del Proyecto
- `lib/main.dart`: Punto de entrada y configuración de temas/rutas.
- `lib/screens/`: Pantallas de la aplicación (Login, Home, etc.).
- `lib/services/`: Lógica de negocio y comunicación HTTP.
- `lib/models/`: Modelos de datos (POJOs).

Para más detalles sobre la arquitectura, consulta el [README principal](../README.md).
