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
    const { toma_id, fecha_real, cumplimiento } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO historial (toma_id, fecha_real, cumplimiento) VALUES ($1, $2, $3) RETURNING *;',
            [toma_id, fecha_real, cumplimiento]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error al crear historial:', err);
        res.status(500).json({ error: 'Error al crear historial' });
    }
};

export const updateHistorial = async (req, res) => {
    const { id } = req.params;
    const { fecha_real, cumplimiento } = req.body;
    try {
        const result = await pool.query(
            'UPDATE historial SET fecha_real = $1, cumplimiento = $2 WHERE id = $3 RETURNING *;',
            [fecha_real, cumplimiento, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error('Error al actualizar historial:', err);
        res.status(500).json({ error: 'Error al actualizar historial' });
    }
};

export const deleteHistorial = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('DELETE FROM historial WHERE id = $1;', [id]);
        res.status(204).send();
    } catch (err) {
        console.error('Error al eliminar historial:', err);
        res.status(500).json({ error: 'Error al eliminar historial' });
    }
};
