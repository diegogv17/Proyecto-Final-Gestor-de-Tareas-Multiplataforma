import express from "express";
const router = express.Router();

import categoryModel from "../models/category.js";
import { verificarToken } from "../helpers/autetication.js";

// CREAR CATEGORÍA
router.post("/", verificarToken, async (req, res) => {
    try {
        const category = await categoryModel.create({
            name: req.body.name,
            color: req.body.color,
            icon: req.body.icon,
            userId: req.user._id
        });

        res.status(201).json(category);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// OBTENER CATEGORÍAS (PARA DROPDOWN)
router.get("/", verificarToken, async (req, res) => {
    try {
        const categories = await categoryModel.getAll(req.user._id);

        res.json(categories);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// OBTENER CATEGORÍA POR ID
router.get("/:id", verificarToken, async (req, res) => {
    try {
        const category = await categoryModel.getOneById(req.params.id);

        if (!category || category.userId.toString() !== req.user._id.toString()) {
            return res.status(404).json({ error: "Categoría no encontrada" });
        }

        res.json(category);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ACTUALIZAR CATEGORÍA
router.put("/:id", verificarToken, async (req, res) => {
    try {
        const category = await categoryModel.update(req.params.id, req.body);

        if (!category) {
            return res.status(404).json({ error: "Categoría no encontrada" });
        }

        res.json(category);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ELIMINAR CATEGORÍA
router.delete("/:id", verificarToken, async (req, res) => {
    try {
        const category = await categoryModel.delete(req.params.id);

        if (!category) {
            return res.status(404).json({ error: "Categoría no encontrada" });
        }

        res.json({ message: "Categoría eliminada" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;