import { pool } from '../db/pool.js';

export const getHistorial = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM historial;');
        res.json(result.rows);
    } catch (err) {
        console.error('Error en consulta historial:', err);
        res.status(500).json({ error: 'Error al obtener historial' });
    }
};
