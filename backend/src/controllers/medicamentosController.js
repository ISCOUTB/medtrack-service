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

export const createMedicamento = async (req, res) => {
    const { nombre, dosis, usuario_id } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO medicamento (nombre, dosis, usuario_id) VALUES ($1, $2, $3) RETURNING *;',
            [nombre, dosis, usuario_id]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error al crear medicamento:', err);
        res.status(500).json({ error: 'Error al crear medicamento' });
    }
};
