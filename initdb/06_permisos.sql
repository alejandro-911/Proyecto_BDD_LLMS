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