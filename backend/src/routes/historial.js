import express from 'express';
import {
    getHistorial,
    createHistorial,
    updateHistorial,
    deleteHistorial
} from '../controllers/historialController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Historial
 *   description: Endpoints para gestionar historial de tomas
 */

/**
 * @swagger
 * /historial:
 *   get:
 *     summary: Obtener todo el historial
 *     tags: [Historial]
 *     responses:
 *       200:
 *         description: Lista de registros de historial
 */
router.get('/', getHistorial);

/**
 * @swagger
 * /historial:
 *   post:
 *     summary: Crear un nuevo registro en historial
 *     tags: [Historial]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               toma_id:
 *                 type: integer
 *               observacion:
 *                 type: string
 *     responses:
 *       201:
 *         description: Registro de historial creado
 */
router.post('/', authenticateToken, createHistorial);

/**
 * @swagger
 * /historial/{id}:
 *   put:
 *     summary: Actualizar un registro de historial por ID
 *     tags: [Historial]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               observacion:
 *                 type: string
 *     responses:
 *       200:
 *         description: Registro de historial actualizado
 */
router.put('/:id', authenticateToken, updateHistorial);

/**
 * @swagger
 * /historial/{id}:
 *   delete:
 *     summary: Eliminar un registro de historial por ID
 *     tags: [Historial]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Registro de historial eliminado
 */
router.delete('/:id', authenticateToken, deleteHistorial);


export default router;