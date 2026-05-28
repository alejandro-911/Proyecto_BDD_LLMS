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

-- para que club_admin pueda SELECT, INSERT, UPDATE, DELETE ON public.reservas TO club_admin
-- lo pueda hacer pero en sus pistas, no en la de todos los clubs
-- Para ello:
-- activamos RLS en la tabla 
ALTER TABLE public.reservas ENABLE ROW LEVEL security;
-- Política: club_admin solo ve/modifica reservas de sus pistas
CREATE POLICY "club_admin_solo_sus_reservas"
ON public.reservas
TO club_admin
USING (
    id_pista IN (
        SELECT p.id_pista FROM public.pista p
        JOIN public.clubs c ON c.id_club = p.id_club
        WHERE c.email_admin = current_setting('request.jwt.claims', true)::json->>'email'
    )
);
/* 
Lo que hace es que cada vez qiie club_admin hace una consulta,
PostgreSQL fitra automátiamente las filas comprobando qu ela pista de esa reseva pertenece al club cuyo 
email_admin coincide con el email del token JWT

Club A hace GET /reservas
        ↓
PostgreSQL comprueba el email del JWT
        ↓
Solo devuelve reservas de pistas del Club A
*/
-- Política para web_user para que pueda seguir viendo todas las reservas y modificarlas (el RLS no le restringe)
CREATE POLICY "web_user_todas_las_reservas"
ON public.reservas
TO web_user
USING (true); -- true significa que no filtra nada , ve todo

-- Política para anon, puede ver todas las reservas del tablón
CREATE POLICY "anon_ver_reservas"
ON public.reservas
TO anon
USING (true);