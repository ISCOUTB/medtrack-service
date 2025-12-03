import express from 'express';
import { getTomas } from '../controllers/tomasController.js';

const router = express.Router();

router.get('/', getTomas);

export default router;