// ============================================================
// Rutas de Usuario (Express Router)
// ============================================================
// Define los endpoints HTTP para el recurso "usuario".
// Cada ruta se asocia a un método del controlador.
// Las rutas protegidas usan el middleware verificarToken.
// ============================================================
import express from 'express';
const route = express.Router();
import usuariosController from '../controllers/user.js';
import { verificarToken } from '../helpers/autetication.js';

// === RUTAS DE AUTENTICACIÓN ===
route.post('/register', usuariosController.register);      // POST /api/auth/register
route.post('/login', usuariosController.login);              // POST /api/auth/login
route.get('/me', verificarToken, usuariosController.me);     // GET  /api/auth/me (protegida)

// === CRUD DE USUARIOS ===
route.get('/', usuariosController.getAll);          // GET    /api/auth
route.get('/:id', usuariosController.getOneById);   // GET    /api/auth/:id
route.put('/:id', usuariosController.update);       // PUT    /api/auth/:id
route.delete('/:id', usuariosController.delete);    // DELETE /api/auth/:id

export default route;
