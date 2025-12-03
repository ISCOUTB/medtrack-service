import express from 'express';
import { getMedicamentos, createMedicamento } from '../controllers/medicamentosController.js';

const router = express.Router();

router.get('/', getMedicamentos);
router.post('/', createMedicamento);

export default router;