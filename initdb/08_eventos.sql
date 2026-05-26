-- Función genérica que lanza el NOTIFY
CREATE OR REPLACE FUNCTION notify_reserva_changes()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM pg_notify(
      'reservas_changes',
      json_build_object('op', TG_OP, 'id_reserva', OLD.id_reserva)::text
    );
  ELSE
    PERFORM pg_notify(
      'reservas_changes',
      json_build_object('op', TG_OP, 'id_reserva', NEW.id_reserva)::text
    );
  END IF;
  RETURN NEW;
END;
$$;

-- Triggers para INSERT, UPDATE y DELETE
CREATE TRIGGER trg_reservas_changes
AFTER INSERT OR UPDATE OR DELETE ON reservas
FOR EACH ROW EXECUTE FUNCTION notify_reserva_changes();