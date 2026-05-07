-- ESQUEMA TABLAS DEL PROYECTO GESTIÓN DE RESERVAS DE PARTIDAS DE PÁDEL

CREATE TABLE Clubs (
    id_club SERIAL PRIMARY KEY,
    nombre_club VARCHAR (255) NOT NULL,
    ciudad VARCHAR (255) NOT NULL
);

-- definición del tipo de ENUM
CREATE TYPE tipo_pista AS ENUM ('Exterior', 'Indoor', 'Cubierta');

CREATE TABLE Pista (
    id_pista SERIAL PRIMARY KEY,
    id_club INT NOT NULL,
    nombre_pista VARCHAR (50) NOT NULL,
    tipo tipo_pista,

    FOREIGN KEY (id_club) REFERENCES Clubs (id_club) ON DELETE CASCADE
);

CREATE TABLE Usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR (255) NOT NULL,
    email_usuario VARCHAR (255) UNIQUE NOT NULL,
    password_usuario VARCHAR (255),
    nivel DECIMAL (2,1) DEFAULT 0.0

);

CREATE TABLE RESERVAS (
    id_reserva SERIAL PRIMARY KEY,
    id_pista INT NOT NULL,
    id_usuario_creador INT NOT NULL,
    id_jd2 INT DEFAULT NULL,
    id_jd3 INT DEFAULT NULL,
    id_jd4 INT DEFAULT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    nivel_partida DECIMAL(2,1), -- 4 dígitos de los cuales 2 son decimales (osea 2 enteros y 2 decimales)

    FOREIGN KEY (id_pista) REFERENCES Pista(id_pista),
    FOREIGN KEY (id_usuario_creador) REFERENCES Usuarios (id_usuario) ON DELETE CASCADE, -- EL CREADOR EN CASCADE porque si se borra, se borra la partida/reserva
    FOREIGN KEY (id_jd2) REFERENCES Usuarios (id_usuario) ON DELETE SET NULL, -- si un jugador se borra se libera el hueco (quedaría libre, null)
    FOREIGN KEY (id_jd3) REFERENCES Usuarios (id_usuario) ON DELETE SET NULL,
    FOREIGN KEY (id_jd4) REFERENCES Usuarios (id_usuario) ON DELETE SET NULL,

    CONSTRAINT reserva_unica UNIQUE (id_pista, fecha, hora)
);

-- Permisos para anon (no autenticados): solo ver el tablón
GRANT SELECT ON public.clubs TO anon;
GRANT SELECT ON public.pista TO anon;
GRANT SELECT ON public.reservas TO anon;

-- Permisos para web_user (autenticación): todo

GRANT SELECT, INSERT, UPDATE ON public.clubs TO web_user;
GRANT SELECT, INSERT, UPDATE ON public.pista TO web_user;
GRANT SELECT, INSERT, UPDATE ON public.usuarios TO web_user;
GRANT SELECT, INSERT, UPDATE ON public.reservas TO web_user;

-- Permisos sobre las secuencias (necesario para INSERT con SERIAL)
GRANT USAGE , SELECT ON ALL SEQUENCES IN SCHEMA public TO web_user;
-- aloemjor hacer el diagrama con mermaid con ia o sacandolo de pgadmin