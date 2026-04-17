import express from 'express';
const router = express.Router();
import taskController from '../controllers/task.js';
import { verificarToken } from '../helpers/autetication.js';

// Todas las rutas requieren autenticación
router.use(verificarToken);

// CRUD de tareas
router.get('/', taskController.getAll);
router.get('/:id', taskController.getOneById);
router.post('/', taskController.create);
router.put('/:id', taskController.update);
router.delete('/:id', taskController.delete);

export default router;