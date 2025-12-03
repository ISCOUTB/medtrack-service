CREATE TABLE IF NOT EXISTS usuario (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS medicamento (
    id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES usuario(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    dosis VARCHAR(50),
    frecuencia VARCHAR(50),
    notas TEXT
);

CREATE TABLE IF NOT EXISTS toma (
    id SERIAL PRIMARY KEY,
    medicamento_id INT REFERENCES medicamento(id) ON DELETE CASCADE,
    fecha_programada TIMESTAMP NOT NULL,
    tomada BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS historial (
    id SERIAL PRIMARY KEY,
    toma_id INT REFERENCES toma(id) ON DELETE CASCADE,
    fecha_real TIMESTAMP,
    cumplimiento BOOLEAN
);

CREATE INDEX IF NOT EXISTS idx_medicamento_usuario ON medicamento(usuario_id);
CREATE INDEX IF NOT EXISTS idx_toma_medicamento ON toma(medicamento_id);
CREATE INDEX IF NOT EXISTS idx_toma_fecha ON toma(fecha_programada);
