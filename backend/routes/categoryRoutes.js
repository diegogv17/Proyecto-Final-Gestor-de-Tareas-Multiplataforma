import express from 'express';
import { verificarToken } from '../helpers/autetication.js';
import categoryControllers from '../controllers/category.js';

const router = express.Router();

// GET /api/categories → { categories: [...] }
router.get('/', verificarToken, (req, res) => categoryControllers.getAll(req, res));

// GET /api/categories/:id → { category, tasks: [...] }
router.get('/:id', verificarToken, (req, res) =>
  categoryControllers.getOneById(req, res),
);

// POST /api/categories → { category }
router.post('/', verificarToken, (req, res) => categoryControllers.create(req, res));

// PUT /api/categories/:id → { category }
router.put('/:id', verificarToken, (req, res) => categoryControllers.update(req, res));

// DELETE /api/categories/:id → { message } (solo si no tiene tareas)
router.delete('/:id', verificarToken, (req, res) =>
  categoryControllers.delete(req, res),
);

export default router;
