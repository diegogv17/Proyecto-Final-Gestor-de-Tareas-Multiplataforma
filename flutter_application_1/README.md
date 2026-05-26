# Flutter Task Management App

Una aplicación de gestión de tareas completa construida con Flutter que consume una API Node.js/Express.

## 🎯 Características

- ✅ **Autenticación JWT** - Registro e inicio de sesión seguros
- ✅ **Gestión de Tareas** - Crear, editar, completar y eliminar tareas
- ✅ **Categorías** - Organizar tareas por categorías personalizadas
- ✅ **Filtros Avanzados** - Filtrar por estado, prioridad y categoría
- ✅ **Prioridades** - Baja, Media, Alta, Urgente
- ✅ **Estados** - Pendiente, En Progreso, Completada
- ✅ **Fechas de Vencimiento** - Establecer y visualizar fechas de vencimiento
- ✅ **Dashboard** - Resumen de tareas con estadísticas en tiempo real
- ✅ **Interfaz Moderna** - Diseño Material 3 con animaciones suaves
- ✅ **Estado Global** - Riverpod para manejo eficiente del estado
- ✅ **Enrutamiento** - GoRouter para navegación fluida

## 🏗️ Arquitectura

```
lib/
├── main.dart                          # Entry point
├── config/
│   └── routes.dart                   # GoRouter configuration
├── models/
│   ├── user_model.dart
│   ├── task_model.dart
│   └── category_model.dart
├── services/
│   ├── api_service.dart              # Dio HTTP client con JWT
│   ├── auth_service.dart
│   ├── task_service.dart
│   └── category_service.dart
├── providers/                         # Riverpod state management
│   ├── auth_provider.dart
│   ├── task_provider.dart
│   └── category_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── tasks/
│   │   ├── task_list_screen.dart
│   │   ├── task_detail_screen.dart
│   │   └── task_form_screen.dart
│   ├── categories/
│   │   └── category_screen.dart
│   └── home_screen.dart
├── widgets/
│   └── task_widgets.dart
└── utils/
    ├── constants.dart
    ├── themes.dart
    └── helpers.dart
```

## 📦 Dependencias Principales

- **flutter_riverpod** (^2.6.1) - State management
- **go_router** (^14.8.1) - Navigation
- **dio** (^5.4.0) - HTTP client
- **flutter_secure_storage** (^9.0.0) - Almacenamiento seguro de JWT
- **json_serializable** (^6.6.0) - Serialización JSON
- **google_fonts** (^6.3.3) - Tipografía
- **intl** (^0.20.2) - Internacionalización
- **equatable** (^2.0.5) - Comparación de objetos

## 🚀 Configuración del Backend

La app espera un servidor Backend en:

```
http://localhost:3000/api
```

### Endpoints Requeridos

#### Autenticación
- `POST /auth/register` - Crear nueva cuenta
- `POST /auth/login` - Iniciar sesión
- `GET /auth/me` - Obtener usuario actual

#### Tareas
- `GET /tasks` - Obtener todas las tareas (con filtros opcionales)
- `GET /tasks/:id` - Obtener tarea específica
- `POST /tasks` - Crear nueva tarea
- `PUT /tasks/:id` - Actualizar tarea
- `DELETE /tasks/:id` - Eliminar tarea

#### Categorías
- `GET /categories` - Obtener todas las categorías
- `GET /categories/:id` - Obtener categoría específica
- `POST /categories` - Crear nueva categoría
- `PUT /categories/:id` - Actualizar categoría
- `DELETE /categories/:id` - Eliminar categoría

## 🔐 Autenticación

- **Token Storage**: Almacenado en flutter_secure_storage
- **Token Header**: `Authorization: Bearer {token}`
- **Interceptores Dio**: Automáticamente inyectan el token en cada request
- **Error 401**: Redirecciona a login si el token expira

## 🎨 Temas

- **Color Primario**: #6366F1 (Índigo)
- **Color Secundario**: #10B981 (Verde)
- **Color de Error**: #EF4444 (Rojo)
- **Tipografía**: Montserrat (títulos) + Open Sans (cuerpo)

### Colores de Prioridad
- **Baja**: #10B981 (Verde)
- **Media**: #F59E0B (Ámbar)
- **Alta**: #EF4444 (Rojo)
- **Urgente**: #7C3AED (Púrpura)

## 📝 Flujo de Autenticación

1. Usuario se registra o inicia sesión
2. Backend devuelve JWT token
3. Token se almacena en flutter_secure_storage
4. Cada request incluye el token en el header
5. Si el token expira, se redirecciona a login

## 🔄 Flujo de Datos

```
UI Screen → Provider (Riverpod) → Service → API Service → Backend
                ↓
           State Management
                ↓
            UI Actualizada
```

## 📲 Pantallas

### Login & Register
- Validación de email y contraseña
- Campos de contraseña seguros
- Toggle para mostrar/ocultar contraseña
- Link a registro/login

### Home Dashboard
- Resumen de tareas (Total, Pendientes, En Progreso, Completadas)
- Acciones rápidas (Nueva Tarea, Categorías, Ver Todas)
- Información del usuario
- Pull-to-refresh

### Task List
- Lista de todas las tareas
- Filtros por estado y prioridad
- Cards de tareas con información destacada
- Acciones: Ver detalle, eliminar

### Task Detail
- Vista completa de la tarea
- Información de: título, descripción, categoría, prioridad, estado, fecha
- Botones para editar y eliminar

### Task Form
- Crear o editar tareas
- Campos: título, descripción, categoría, estado, prioridad, fecha
- Validaciones en tiempo real
- Date picker para vencimiento

### Categories
- Lista de categorías con colores
- Crear nueva categoría
- Color picker con colores predefinidos
- Eliminar categorías

## 🛠️ Desarrollo

### Generar código JSON

```bash
flutter pub run build_runner build
```

### Ejecutar la app

```bash
flutter run
```

### Build para producción

```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

## ✅ Testing

Las pantallas incluyen:
- Manejo de estados (loading, data, error)
- Validación de formularios
- Mensajes de error amigables
- Indicadores de carga

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

## 🐛 Manejo de Errores

- **Conexión**: Timeout y conexión rechazada
- **Autenticación**: 401 - No autorizado
- **Validación**: Campos requeridos y formato
- **Servidor**: 500 - Error del servidor
- **Mensajes**: SnackBars amigables en español

## 📚 Notas de Implementación

- Los modelos usan `@JsonSerializable()` para generación automática
- Los providers usan `StateNotifier` para manejo de estado mutable
- El router usa `redirect` para proteger rutas basadas en autenticación
- Los interceptores de Dio manejan automáticamente tokens

## 🚪 Mejoras Futuras

- [ ] Búsqueda y filtros avanzados
- [ ] Notificaciones de tareas
- [ ] Sincronización offline
- [ ] Exportar tareas
- [ ] Dark mode
- [ ] Múltiples idiomas
- [ ] Análisis de productividad
- [ ] Colaboración en tareas

## 📄 Licencia

Este proyecto es parte del Proyecto Final - Gestor de Tareas Multiplataforma.
