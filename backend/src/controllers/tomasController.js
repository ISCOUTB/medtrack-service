import { pool } from '../db/pool.js';

export const getTomas = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM toma;');
        res.json(result.rows);
    } catch (err) {
        console.error('Error en consulta tomas:', err);
        res.status(500).json({ error: 'Error al obtener tomas' });
    }
};

export const createToma = async (req, res) => {
    const { medicamento_id, fecha_hora, realizada } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO toma (medicamento_id, fecha_hora, realizada) VALUES ($1, $2, $3) RETURNING *;',
            [medicamento_id, fecha_hora, realizada]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error al crear toma:', err);
        res.status(500).json({ error: 'Error al crear toma' });
    }
};
