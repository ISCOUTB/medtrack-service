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
    const { medicamento_id, fecha_programada } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO toma (medicamento_id, fecha_programada) VALUES ($1, $2) RETURNING *;',
            [medicamento_id, fecha_programada]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error al crear toma:', err);
        res.status(500).json({ error: 'Error al crear toma' });
    }
};

export const updateToma = async (req, res) => {
    const { id } = req.params;
    const { fecha_programada } = req.body;
    try {
        const result = await pool.query(
            'UPDATE toma SET fecha_programada = $1 WHERE id = $2 RETURNING *;',
            [fecha_programada, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error('Error al actualizar toma:', err);
        res.status(500).json({ error: 'Error al actualizar toma' });
    }
};

export const deleteToma = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('DELETE FROM toma WHERE id = $1;', [id]);
        res.status(204).send();
    } catch (err) {
        console.error('Error al eliminar toma:', err);
        res.status(500).json({ error: 'Error al eliminar toma' });
    }
};

export const registrarToma = async (req, res) => {
    const { medicamento_id, fecha_hora, estado, fecha_programada } = req.body;
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        
        const scheduledTime = fecha_programada || fecha_hora;
        const status = estado || 'TOMADO';

        const existingToma = await client.query(
            'SELECT id FROM toma WHERE medicamento_id = $1 AND fecha_programada = $2',
            [medicamento_id, scheduledTime]
        );

        let tomaId;

        if (existingToma.rows.length > 0) {
            tomaId = existingToma.rows[0].id;
            await client.query(
                'UPDATE toma SET tomada = $1, estado = $2, fecha_real = $3 WHERE id = $4',
                [status === 'TOMADO', status, fecha_hora, tomaId]
            );
        } else {
            const tomaRes = await client.query(
                'INSERT INTO toma (medicamento_id, fecha_programada, tomada, estado, fecha_real) VALUES ($1, $2, $3, $4, $5) RETURNING id;',
                [medicamento_id, scheduledTime, status === 'TOMADO', status, fecha_hora]
            );
            tomaId = tomaRes.rows[0].id;
        }

        await client.query(
            'INSERT INTO historial (toma_id, fecha_real, cumplimiento) VALUES ($1, $2, $3);',
            [tomaId, fecha_hora, status === 'TOMADO']
        );

        await client.query('COMMIT');
        res.status(201).json({ message: 'Toma registrada/actualizada exitosamente', tomaId });
    } catch (err) {
        await client.query('ROLLBACK');
        console.error('Error al registrar toma:', err);
        res.status(500).json({ error: 'Error al registrar toma' });
    } finally {
        client.release();
    }
};

export const getTomaHistorial = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query(
            `SELECT h.id, h.observacion, h.toma_id
       FROM historial h
       INNER JOIN toma t ON h.toma_id = t.id
       WHERE t.id = $1;`,
            [id]
        );
        res.json(result.rows);
    } catch (err) {
        console.error('Error al obtener historial de la toma:', err);
        res.status(500).json({ error: 'Error al obtener historial de la toma' });
    }
};

export const getTomasByUsuario = async (req, res) => {
    const { usuario_id } = req.params;
    const { fecha } = req.query;

    try {
        let query = `
            SELECT t.*, m.nombre as medicamento_nombre, m.dosis as medicamento_dosis
            FROM toma t
            INNER JOIN medicamento m ON t.medicamento_id = m.id
            WHERE m.usuario_id = $1
        `;
        const params = [usuario_id];

        if (fecha) {
            query += ` AND DATE(t.fecha_programada) = $2`;
            params.push(fecha);
        }
        
        query += ` ORDER BY t.fecha_programada DESC, t.id DESC`;

        const result = await pool.query(query, params);
        res.json(result.rows);
    } catch (err) {
        console.error('Error al obtener tomas del usuario:', err);
        res.status(500).json({ error: 'Error al obtener tomas del usuario' });
    }
};
