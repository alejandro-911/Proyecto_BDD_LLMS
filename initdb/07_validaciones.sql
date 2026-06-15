-- Así postgreSQL lo rechaza automáticamente antes de insertar si está dentro de la misma hora y media 

CREATE OR REPLACE FUNCTION check_solapamiento()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM reservas
        WHERE id_pista = NEW.id_pista -- misma pista 
        AND fecha = NEW.fecha -- mismo día 
        AND ABS(EXTRACT(EPOCH FROM (hora - NEW.hora)) / 3600) < 1.5 -- dentro de 1.5h, 3600 s tiene una h, EXTRAT(EPOCH FROM ...) convierte la diferencia de horas a segundos, dividido entre 3600 --> da horas
        -- AND id_reserva != NEW.id_reserva esto no es necesario en un trigger BEFORE INSERT porque l afila todavía no existe en la tabla, así que no puede compararse consigo misma 
    ) THEN
        RAISE EXCEPTION 'La pista ya está ocupada en ese horario';
    END IF;
    RETURN NEW; -- devuelve NEW y permite la inserción
END;
$$;

CREATE TRIGGER trigger_solapamiento
BEFORE INSERT ON reservas
FOR EACH ROW EXECUTE FUNCTION check_solapamiento();

-- Para validar el nivel de un jugador

-- REGLA DE NEGOCIO: no permitir reservas a partir de las 23:30
-- En 07_validaciones.sql añades:
CREATE OR REPLACE FUNCTION check_horario()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.fecha < CURRENT_DATE OR 
    (NEW.fecha = CURRENT_DATE AND NEW.hora < CURRENT_TIME) THEN
        RAISE EXCEPTION 'No se puede reservar en una fecha pasada';
    END IF;
    IF NEW.hora > '23:30:00' THEN
        RAISE EXCEPTION 'No se puede reservar después de las 23:30';
    END IF;
    IF NEW.hora < '06:00:00' THEN
    RAISE EXCEPTION 'No se puede reservar antes de las 6:00';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_horario
BEFORE INSERT ON reservas
FOR EACH ROW EXECUTE FUNCTION check_horario();