CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pgjwt;

CREATE SCHEMA basic_auth;

-- Tabla interna de autenticación 
CREATE TABLE basic_auth.users (
    email TEXT CHECK (email ~* '^.+@.+\..+$'),
    pass TEXT NOT NULL CHECK (length(pass) < 512),
    role NAME NOT NULL CHECK (length(role) < 512),
    PRIMARY KEY (email)
);

-- Función que comprueba que el rol existe 
CREATE FUNCTION basic_auth.check_role_exist()
RETURNS TRIGGER LANGUAGE plpgsql AS $function$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles AS r WHERE r.rolname = NEW.role) THEN
        RAISE foreign_key_violation
        USING message = 'unknown database role: ' ||NEW.role;
        RETURN NULL;
    END IF;
    RETURN NEW;
END
$function$;

CREATE CONSTRAINT TRIGGER asegurar_user_role_exist
AFTER INSERT OR UPDATE ON basic_auth.users
FOR EACH ROW EXECUTE FUNCTION basic_auth.check_role_exist();

-- Function que cifra la contraseña automáticamente
CREATE FUNCTION basic_auth.encrypt_pass()
RETURNS TRIGGER LANGUAGE plpgsql AS $function$
BEGIN 
    IF tg_op = 'INSERT' OR NEW.pass <> OLD.pass THEN 
        NEW.pass = crypt(NEW.pass, gen_salt('bf'));
    END IF;
    RETURN NEW;
END
$function$;

CREATE TRIGGER encrypt_pass
BEFORE INSERT OR UPDATE ON basic_auth.users
FOR EACH ROW EXECUTE FUNCTION basic_auth.encrypt_pass();

-- Función que verifica el email y contraseña y devuelve el rol
-- Igual cambiar los nombres de parámetros para evitar ambigüedad (_email TEXT, _pass TEXT)
CREATE FUNCTION basic_auth.user_role(email TEXT, pass TEXT)
RETURNS NAME LANGUAGE plpgsql AS $function$ 
BEGIN
    RETURN (
        SELECT role FROM basic_auth.users
        WHERE users.email = user_role.email -- aqui se usaría con guión bajo _email
        AND users.pass = crypt(user_role.pass, users.pass) -- aquí _pass      
    );
END
$function$;

-- Función de LOGIN: devuelve un token JWT 
CREATE FUNCTION login (email TEXT, pass TEXT, OUT token TEXT)
LANGUAGE plpgsql SECURITY DEFINER AS $function$ 
DECLARE 
    _role NAME;
BEGIN
    SELECT basic_auth.user_role(email, pass) INTO _role;
    IF _role IS NULL THEN 
        RAISE invalid_password USING message = 'invalid user or password';
    END IF;

    SELECT sign(row_to_json(r), current_setting('app.settings.jwt_secret')) AS token
    FROM (
        SELECT _role AS role,
        login.email AS email,
        extract(epoch FROM now())::integer
            + current_setting('app.settings.jwt_exp')::integer AS exp
    ) r INTO token;
END 
$function$;

-- Función de SIGNUP adaptada a mi PROYECTO
-- Posible correción cifrado de pass en ambas tablas
CREATE FUNCTION signup(
    email TEXT,
    pass TEXT, 
    nombre TEXT,
    nivel DECIMAL 

) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $function$
BEGIN
    -- Inserta en la tabla de autenticación (el Trigger cifrará la pass)
    INSERT INTO basic_auth.users (email, pass, role)
    VALUES (signup.email, signup.pass, 'web_user');

    -- Inserta en tu tabla de Usuarios con nombre y nivel (Ojo: aquí la pass se guarda plana, ***REVISAR***)
    -- igual poner: VALUES (nombre, email, crypt(pass, gen_salt('bf')), nivel);.
    INSERT INTO public.usuarios (nombre_usuario, email_usuario, password_usuario, nivel)
    VALUES (nombre, email, crypt(pass, gen_salt('bf')), nivel);
END 
$function$;

-- permisos
GRANT USAGE ON SCHEMA public TO anon, web_user;
GRANT USAGE ON SCHEMA basic_auth TO anon, web_user;
-- GRANT SELECT ON TABLE basic_auth.users TO web_user; -- A veces necesario según la lógica
GRANT EXECUTE ON FUNCTION login(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION signup(TEXT, TEXT, TEXT, DECIMAL) TO anon;

-- La diferencia respecto a la practica anterior, está en la función SIGNUP(). 
-- en la prcatuca recibia email y password, aquí recibe también nombre y nivel,
-- e inserta en dos tablas a la vez para la autenticación (basic_auth.users)
-- y para los datos del jugador  (public.usuarios)


