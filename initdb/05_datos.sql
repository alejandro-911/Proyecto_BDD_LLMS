-- 1. Insertar Clubs
INSERT INTO Clubs (nombre_club, ciudad, email_admin) VALUES 
('Padel Indoor Granvia', 'Barcelona', 'club1@padel.com'),
('Club Padel Viladecans', 'Viladecans', 'club2@padel.com'),
('Padel Sant Boi', 'Sant Boi', 'club3@padel.com');

-- 2. Insertar usuarios de los clubs en basic_auth (el trigger cifrará la pass)
INSERT INTO basic_auth.users (email, pass, role) VALUES
('club1@padel.com', '1234', 'club_admin'),
('club2@padel.com', '1234', 'club_admin'),
('club3@padel.com', '1234', 'club_admin');

-- 3. Insertar Pistas
INSERT INTO Pista (id_club, nombre_pista, tipo) VALUES 
(1, 'Pista 1 - Central', 'Indoor'),
(1, 'Pista 2', 'Indoor'),
(2, 'Pista Exterior Panorámica', 'Exterior'),
(3, 'Pista Cubierta 1', 'Cubierta');

/*
Credenciales de prueba:
- Clubs: club1@padel.com, club2@padel.com, club3@padel.com (pass: 1234)
*/