🚀 STACKFLOW - Gestor de Tareas Multiplataforma

STACKFLOW es una aplicación de gestión de tareas desarrollada como proyecto académico para el curso de Programación III de la Universidad San Pablo de Guatemala.

El sistema permite a los usuarios crear, organizar y administrar tareas personales mediante una plataforma moderna con autenticación segura, categorías personalizadas, filtros por estado y prioridad, además de clientes web y móvil conectados a una API REST centralizada.

---

✨ Características

- Registro e inicio de sesión de usuarios
- Autenticación mediante JWT
- Gestión completa de tareas (CRUD)
- Gestión de categorías personalizadas
- Filtros por estado y prioridad
- Dashboard con estadísticas de tareas
- Aplicación web desarrollada en Angular
- Aplicación móvil desarrollada en Flutter
- Backend desarrollado con Node.js, Express y MongoDB
- Arquitectura escalable basada en API REST

---

🛠️ Tecnologías Utilizadas

Backend

- Node.js
- Express 5
- MongoDB Atlas
- Mongoose
- JWT
- bcrypt

Frontend Web

- Angular 21
- TypeScript
- Signals
- Standalone Components

Frontend Móvil

- Flutter
- Riverpod
- GoRouter
- Dio

---

📁 Estructura del Proyecto

Proyecto-Final-Gestor-de-Tareas-Multiplataforma/

├── backend/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── schemas/
│   └── index.js
│
├── frontend-web/
│   └── Angular
│
├── frontend-mobile/
│   └── Flutter
│
└── README.md

---

⚙️ Requisitos Previos

Antes de iniciar el proyecto asegúrate de tener instalado:

- Node.js 16 o superior
- npm
- MongoDB Atlas o MongoDB local
- Angular CLI
- Flutter SDK (opcional para la aplicación móvil)

Verificar instalación:

node -v
npm -v
flutter --version

---

🔧 Configuración del Backend

Ingresar a la carpeta del backend:

cd backend

Instalar dependencias:

npm install

Crear un archivo ".env":

PORT=5100

MONGODB_URI=tu_cadena_de_conexion

JWT_SECRET=tu_clave_secreta

---

▶️ Ejecutar Backend

npm start

o

node index.js

Servidor disponible en:

http://localhost:5100

Prueba rápida:

http://localhost:5100/api/health

Respuesta esperada:

{
  "status": "OK"
}

---

🌐 Configuración Frontend Web (Angular)

Ingresar a la carpeta:

cd frontend-web

Instalar dependencias:

npm install

Verificar que la URL de la API apunte al backend:

http://localhost:5100/api

Ejecutar proyecto:

ng serve

Abrir en navegador:

http://localhost:4200

---

📱 Configuración Frontend Móvil (Flutter)

Ingresar a la carpeta:

cd frontend-mobile

Instalar dependencias:

flutter pub get

Configurar la URL base:

const String baseUrl = 'http://localhost:5100/api';

Si se usa emulador Android:

const String baseUrl = 'http://10.0.2.2:5100/api';

Ejecutar aplicación:

flutter run

---

🔐 Autenticación

El sistema utiliza JSON Web Tokens (JWT).

Proceso:

1. Usuario inicia sesión.
2. El backend genera un token.
3. El cliente almacena el token.
4. Cada petición protegida envía:

Authorization: Bearer TOKEN

---

📌 Endpoints Principales

Autenticación

POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me

Tareas

GET    /api/tasks
POST   /api/tasks
PUT    /api/tasks/:id
DELETE /api/tasks/:id

Categorías

GET    /api/categories
POST   /api/categories
PUT    /api/categories/:id
DELETE /api/categories/:id

---

👨‍💻 Integrantes

- Diego Alejandro Gómez Vásquez
- Karla Betzabé Osorio Dávila
- Dallin Eleazar Osorio Cruz
- Jennifer Gabriela Duque Ventura

Universidad San Pablo de Guatemala

Ingeniería en Sistemas y Ciencias de la Computación

Programación III

2026

---

📄 Licencia

Este proyecto fue desarrollado con fines académicos y educativos.

Licencia ISC.
