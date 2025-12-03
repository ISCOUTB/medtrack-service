import express from 'express';
import {
    getTomas,
    createToma,
    updateToma,
    deleteToma,
    getTomaHistorial
} from '../controllers/tomasController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Tomas
 *   description: Endpoints para gestionar tomas de medicamentos
 */

/**
 * @swagger
 * /tomas:
 *   get:
 *     summary: Obtener todas las tomas
 *     tags: [Tomas]
 *     responses:
 *       200:
 *         description: Lista de tomas
 */
router.get('/', getTomas);

/**
 * @swagger
 * /tomas:
 *   post:
 *     summary: Crear una nueva toma
 *     tags: [Tomas]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               medicamento_id:
 *                 type: integer
 *               fecha_hora:
 *                 type: string
 *                 format: date-time
 *               realizada:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Toma creada
 */
router.post('/', authenticateToken, createToma);

/**
 * @swagger
 * /tomas/{id}:
 *   put:
 *     summary: Actualizar una toma por ID
 *     tags: [Tomas]
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
 *               fecha_hora:
 *                 type: string
 *                 format: date-time
 *               realizada:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Toma actualizada
 */
router.put('/:id', authenticateToken, updateToma);

/**
 * @swagger
 * /tomas/{id}:
 *   delete:
 *     summary: Eliminar una toma por ID
 *     tags: [Tomas]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Toma eliminada
 */
router.delete('/:id', authenticateToken, deleteToma);

/**
 * @swagger
 * /tomas/{id}/historial:
 *   get:
 *     summary: Obtener historial asociado a una toma
 *     tags: [Tomas]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Historial de la toma
 */
router.get('/:id/historial', getTomaHistorial);

export default router;