import express from 'express';
import { getMedicamentos, createMedicamento, updateMedicamento, deleteMedicamento, getMedicamentoTomas } from '../controllers/medicamentosController.js';

const router = express.Router();

router.get('/', getMedicamentos);
router.post('/', createMedicamento);
router.put('/:id', updateMedicamento);
router.delete('/:id', deleteMedicamento);

router.get('/:id/tomas', getMedicamentoTomas);

export default router;