import express from 'express';
import { getHistorial, createHistorial } from '../controllers/historialController.js';

const router = express.Router();

router.get('/', getHistorial);
router.post('/', createHistorial);

export default router;