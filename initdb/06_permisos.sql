-- anon: solo puede ver el tablón y las pistas (sin estar registrado)
GRANT SELECT ON public.clubs TO anon;
GRANT SELECT ON public.pista TO anon;
GRANT SELECT ON public.reservas TO anon;

-- web_user: puede hacer todo una vez autenticado
GRANT SELECT, INSERT, UPDATE, DELETE ON public.clubs TO web_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pista TO web_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.usuarios TO web_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.reservas TO web_user;

-- Necesario para que los INSERT con SERIAL funcionen
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO web_user;

-- Permisos para ejecutar las funciones de autenticación
GRANT EXECUTE ON FUNCTION login(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION signup(TEXT, TEXT, TEXT, DECIMAL) TO anon;

/* 

* anon solo puede leer clubs, pistas y reservas, para ver el tablón sin estar registrado
* web_user puede hacer todo porque ya está autenticado
* anon puede ejecutar login y signup porque son las funciones que necesita para autenticarse

*/

-- club_admin PUEDE VER Y GESTIONAR RESERVAS DE SUS PISTAS
GRANT SELECT, INSERT, UPDATE, DELETE ON public.reservas TO club_admin;

-- permiso solo de lectura de pista, clubs y usuarios para consultar información pero no modificarla
GRANT SELECT ON public.pista TO club_admin;
GRANT SELECT ON public.clubs TO club_admin;
GRANT SELECT ON public.usuarios TO club_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO club_admin;
GRANT EXECUTE ON FUNCTION signup_club(TEXT, TEXT, TEXT, TEXT) TO anon;
-- esto es porque un usuario que no esta registrado ni nada pueda usar la función de registrarse
-- GRANT EXECUTE ON FUNCTION signup_club(TEXT, TEXT, TEXT, TEXT) TO anon;
-- sin estar registrado necesitas como mínimo registrarse y hacer login
-- sino nadie podría entrar en la app nunca