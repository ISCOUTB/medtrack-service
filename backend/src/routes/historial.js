import express from 'express';
import { getHistorial, createHistorial, updateHistorial, deleteHistorial } from '../controllers/historialController.js';

const router = express.Router();

router.get('/', getHistorial);
router.post('/', createHistorial);
router.put('/:id', updateHistorial);
router.delete('/:id', deleteHistorial);

export default router;