import { pool } from '../db/pool.js';

export const getUsuarios = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM usuario;');
        res.json(result.rows);
    } catch (err) {
        console.error('Error en consulta usuarios:', err);
        res.status(500).json({ error: 'Error al obtener usuarios' });
    }
};
