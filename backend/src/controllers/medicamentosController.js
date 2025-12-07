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
    const { usuario_id, nombre, dosis, frecuencia, notas, detalles_frecuencia } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO medicamento (usuario_id, nombre, dosis, frecuencia, notas, detalles_frecuencia) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *;',
            [usuario_id, nombre, dosis, frecuencia, notas, detalles_frecuencia]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error al crear medicamento:', err);
        res.status(500).json({ error: 'Error al crear medicamento' });
    }
};

export const updateMedicamento = async (req, res) => {
    const { id } = req.params;
    const { nombre, dosis, frecuencia, notas, detalles_frecuencia } = req.body;
    try {
        const result = await pool.query(
            'UPDATE medicamento SET nombre = $1, dosis = $2, frecuencia = $3, notas = $4, detalles_frecuencia = $5 WHERE id = $6 RETURNING *;',
            [nombre, dosis, frecuencia, notas, detalles_frecuencia, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error('Error al actualizar medicamento:', err);
        res.status(500).json({ error: 'Error al actualizar medicamento' });
    }
};

export const deleteMedicamento = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('DELETE FROM medicamento WHERE id = $1;', [id]);
        res.status(204).send();
    } catch (err) {
        console.error('Error al eliminar medicamento:', err);
        res.status(500).json({ error: 'Error al eliminar medicamento' });
    }
};

export const getMedicamentoTomas = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query(
            `SELECT t.id, t.fecha_hora, t.realizada
       FROM toma t
       INNER JOIN medicamento m ON t.medicamento_id = m.id
       WHERE m.id = $1;`,
            [id]
        );
        res.json(result.rows);
    } catch (err) {
        console.error('Error al obtener tomas del medicamento:', err);
        res.status(500).json({ error: 'Error al obtener tomas del medicamento' });
    }
};
