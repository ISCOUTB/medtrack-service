import express from 'express';
import { getTomas, createToma, updateToma, deleteToma } from '../controllers/tomasController.js';

const router = express.Router();

router.get('/', getTomas);
router.post('/', createToma);
router.put('/:id', updateToma);
router.delete('/:id', deleteToma);

export default router;