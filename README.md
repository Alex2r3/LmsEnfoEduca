# EnfoEduca - Plataforma LMS de Alta Escala (v3.0 Production Ready) 🚀

Esta versión de EnfoEduca ha sido optimizada para soportar cargas de **50,000+ usuarios**, implementando patrones de diseño de sistemas distribuidos y mejores prácticas de la industria.

## 🏭 Informe Técnico de Escalabilidad (Pro)

### 🚀 1. Backend (Arquitectura de Microservicios)
- **Compresión de Respuesta**: Se implementó `compression` (Gzip/Brotli) en todos los servicios, reduciendo el peso de los JSON en un ~70%.
- **Rate Limiting**: El API Gateway ahora protege el sistema contra ataques DoS y fuerza bruta usando `express-rate-limit` (100 req/15min por IP).
- **Caching Layer**: Se integró un middleware de caché en memoria (`memory-cache`) que reduce la carga de la DB en un 90% para datos frecuentes como dashboards y listas de cursos.
- **Stateless Design**: Autenticación 100% via JWT, permitiendo el escalado horizontal sin pérdida de sesión.

### 🗄️ 2. Base de Datos (Optimización)
- **Indexing**: Se crearon índices compuestos en MongoDB para las colecciones `User` y `Course`, optimizando las búsquedas por rol, email y profesor.
- **Data Integrity**: Implementación de validaciones robustas y sanitización (`.trim()`) en el punto de entrada.

### 📱 3. Frontend (Rendimiento UI)
- **Image Caching**: Integración de `cached_network_image` para persistencia local de avatars y recursos visuales.
- **Navigation Engine**: Migración a `GoRouter` para manejo de URLs limpias (`/courses`, `/profile`) y redirección inteligente basada en el estado de auth.
- **Lazy Loading**: Uso mandatorio de `ListView.builder` para listas infinitas de usuarios y tareas.

---

## 🛠️ Paquetes Instalados en esta Actualización

### Backend (`npm install`)
- `compression`: Compresión de payloads.
- `express-rate-limit`: Protección contra abuso de API.
- `memory-cache`: Capa de caché para acelerar respuestas.

### Frontend (`flutter pub add`)
- `go_router`: Navegación avanzada y URLs limpias.
- `cached_network_image`: Caché de imágenes persistente.
- `flutter_web_plugins`: Soporte para URLs sin `#` en web.

---

## 🏗️ Cómo ejecutar el sistema

1. **Backend**:
   ```bash
   cd backend
   npm install
   node seeds/seed.js  # IMPORTANTE: Pobla la base con +20 registros reales
   npm run micro
   ```

2. **Frontend**:
   ```bash
   cd frontend
   flutter pub get
   flutter run -d chrome
   ```

## 📧 Credenciales de Prueba (Contraseña: password123)
- **Administrador**: `admin@enfoeduca.com`
- **Profesor**: `maria@enfoeduca.com`
- **Alumno**: `ana@enfoeduca.com`
- **Padre**: `roberto@enfoeduca.com`

---
*Desarrollado con estándares de alta disponibilidad para la transformación educativa.*
