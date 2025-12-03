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

export const createHistorial = async (req, res) => {
    const { toma_id, observacion } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO historial (toma_id, observacion) VALUES ($1, $2) RETURNING *;',
            [toma_id, observacion]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error al crear historial:', err);
        res.status(500).json({ error: 'Error al crear historial' });
    }
};
