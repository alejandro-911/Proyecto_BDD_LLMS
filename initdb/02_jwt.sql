-- comando de psql (noSQL) que lee las variables de entorno JWT_SECRET y JWT_EXP del sistema
-- (las que están definidas en el docker-compose) y las guarda en variables de psql para usarlas después 
\set jwt_secret `echo "$JWT_SECRET"`
\set jwt_exp `echo "$JWT_EXP"`
-- Guarda esos valores dentro de la propia base de datos como configuración global.
-- Así cualquier función SQL puede leerlos después con current_setting('app.settings.jwt_secret')
ALTER DATABASE postgres SET app.settings.jwt_secret = :'jwt_secret';
ALTER DATABASE postgres SET app.settings.jwt_exp = :'jwt_exp';
-- Se verá en acción en el 03_auth.sql cuando la función login() genera el token JWT, usa exactamente esto:
-- current_setting('app.settings.jwt_secret')

-- En resumen, estos dos archivos son la "configuración previa" que necesitan las funciones de autenticación
-- para funcionar. sin ellos, login() no sabría con que clave firmar el token ni cuánto tiempo debe durar