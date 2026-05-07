-- 1. Insertar Clubs
INSERT INTO Clubs (nombre_club, ciudad) VALUES 
('Padel Indoor Granvia', 'Barcelona'),
('Club Padel Viladecans', 'Viladecans'),
('Padel Sant Boi', 'Sant Boi');

-- 2. Insertar Pistas (usando el ENUM tipo_pista)
INSERT INTO Pista (id_club, nombre_pista, tipo) VALUES 
(1, 'Pista 1 - Central', 'Indoor'),
(1, 'Pista 2', 'Indoor'),
(2, 'Pista Exterior Panorámica', 'Exterior'),
(3, 'Pista Cubierta 1', 'Cubierta');

-- 3. Insertar Usuarios
INSERT INTO Usuarios (nombre_usuario, email_usuario, password_usuario, nivel) VALUES 
('Marc Entrenador', 'marc@padel.com', 'scrypt_o_texto_plano', 5.0),
('Ana García', 'ana@gmail.com', '1234', 3.5),
('David López', 'david@yahoo.es', '1234', 2.0),
('Laura Martínez', 'laura@outlook.com', '1234', 4.2),
('Usuario Invitado', 'invitado@test.com', '1234', 1.5);

-- 4. Insertar Reservas (Partidas)
-- Escenario A: Partida completa
INSERT INTO RESERVAS (id_pista, id_usuario_creador, id_jd2, id_jd3, id_jd4, fecha, hora, nivel_partida) 
VALUES (1, 1, 2, 3, 4, '2026-05-15', '18:00:00', 4.00);

-- Escenario B: Partida con 2 huecos libres (Solo creador y un jugador)
INSERT INTO RESERVAS (id_pista, id_usuario_creador, id_jd2, fecha, hora, nivel_partida) 
VALUES (3, 4, 1, '2026-05-15', '19:30:00', 4.50);

-- Escenario C: Partida recién creada (Solo el creador)
INSERT INTO RESERVAS (id_pista, id_usuario_creador, fecha, hora, nivel_partida) 
VALUES (4, 3, '2026-05-16', '10:00:00', 2.50);