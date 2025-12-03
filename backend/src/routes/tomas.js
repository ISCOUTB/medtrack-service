import express from 'express';
import { getTomas, createToma, updateToma, deleteToma, getTomaHistorial } from '../controllers/tomasController.js';

const router = express.Router();

router.get('/', getTomas);
router.post('/', createToma);
router.put('/:id', updateToma);
router.delete('/:id', deleteToma);

router.get('/:id/historial', getTomaHistorial);

export default router;