import express from 'express';
import { getTomas, createToma } from '../controllers/tomasController.js';

const router = express.Router();

router.get('/', getTomas);
router.post('/', createToma);

export default router;