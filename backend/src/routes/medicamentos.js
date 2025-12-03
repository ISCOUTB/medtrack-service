import express from 'express';
import {
    getMedicamentos,
    createMedicamento,
    updateMedicamento,
    deleteMedicamento,
    getMedicamentoTomas
} from '../controllers/medicamentosController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Medicamentos
 *   description: Endpoints para gestionar medicamentos
 */

/**
 * @swagger
 * /medicamentos:
 *   get:
 *     summary: Obtener todos los medicamentos
 *     tags: [Medicamentos]
 *     responses:
 *       200:
 *         description: Lista de medicamentos
 */
router.get('/', getMedicamentos);

/**
 * @swagger
 * /medicamentos:
 *   post:
 *     summary: Crear un nuevo medicamento
 *     tags: [Medicamentos]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               usuario_id:
 *                 type: integer
 *               nombre:
 *                 type: string
 *               dosis:
 *                 type: string
 *               frecuencia:
 *                 type: string
 *               notas:
 *                 type: string
 *     responses:
 *       201:
 *         description: Medicamento creado
 */
router.post('/', authenticateToken, createMedicamento);

/**
 * @swagger
 * /medicamentos/{id}:
 *   put:
 *     summary: Actualizar un medicamento por ID
 *     tags: [Medicamentos]
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
 *               nombre:
 *                 type: string
 *               dosis:
 *                 type: string
 *     responses:
 *       200:
 *         description: Medicamento actualizado
 */
router.put('/:id', authenticateToken, updateMedicamento);

/**
 * @swagger
 * /medicamentos/{id}:
 *   delete:
 *     summary: Eliminar un medicamento por ID
 *     tags: [Medicamentos]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Medicamento eliminado
 */
router.delete('/:id', authenticateToken, deleteMedicamento);

/**
 * @swagger
 * /medicamentos/{id}/tomas:
 *   get:
 *     summary: Obtener tomas asociadas a un medicamento
 *     tags: [Medicamentos]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Lista de tomas del medicamento
 */
router.get('/:id/tomas', getMedicamentoTomas);


export default router;