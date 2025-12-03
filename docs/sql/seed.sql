INSERT INTO usuario (nombre, email, password_hash)
VALUES ('Álvaro', 'alvaro@example.com', 'hash-demo');

INSERT INTO medicamento (usuario_id, nombre, dosis, frecuencia, notas)
VALUES (1, 'Ibuprofeno', '400 mg', 'Cada 8 horas', 'Tomar con comida');

INSERT INTO toma (medicamento_id, fecha_programada)
VALUES (1, NOW() + INTERVAL '1 hour'),
       (1, NOW() + INTERVAL '9 hours');

INSERT INTO historial (toma_id, fecha_real, cumplimiento)
VALUES (1, NOW() + INTERVAL '70 minutes', TRUE);
