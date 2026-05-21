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