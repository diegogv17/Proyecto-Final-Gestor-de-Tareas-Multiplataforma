import express from 'express';
const route = express.Router();
import usuariosController from '../controllers/user.js';
import { verificarToken } from '../helpers/autetication.js';

// Autenticación
route.post('/register', usuariosController.register);
route.post('/login', usuariosController.login);
route.get('/me', verificarToken, usuariosController.me);

// CRUD de usuarios
route.get('/', usuariosController.getAll);
route.get('/:id', usuariosController.getOneById);
route.put('/:id', usuariosController.update);
route.delete('/:id', usuariosController.delete);

export default route;