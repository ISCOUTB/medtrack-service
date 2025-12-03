import { pool } from '../db/pool.js';

export const getMedicamentos = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM medicamento;');
        res.json(result.rows);
    } catch (err) {
        console.error('Error en consulta medicamentos:', err);
        res.status(500).json({ error: 'Error al obtener medicamentos' });
    }
};
