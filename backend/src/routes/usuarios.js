import express from 'express';
import { getUsuarios, createUsuario, updateUsuario, deleteUsuario, getUsuarioMedicamentos, getUsuarioTomas } from '../controllers/usuariosController.js';

const router = express.Router();

router.get('/', getUsuarios);
router.post('/', createUsuario);
router.put('/:id', updateUsuario);
router.delete('/:id', deleteUsuario);

router.get('/:id/medicamentos', getUsuarioMedicamentos);
router.get('/:id/tomas', getUsuarioTomas);

export default router;
