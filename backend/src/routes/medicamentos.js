import express from 'express';
import { getMedicamentos, createMedicamento, updateMedicamento, deleteMedicamento } from '../controllers/medicamentosController.js';

const router = express.Router();

router.get('/', getMedicamentos);
router.post('/', createMedicamento);
router.put('/:id', updateMedicamento);
router.delete('/:id', deleteMedicamento);

export default router;