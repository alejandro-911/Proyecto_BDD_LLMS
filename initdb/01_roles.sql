-- \set pgpass `echo "$POSTGRES_PASSWORD"`, es un comando de psql (no SQL)
-- que lee la variable de entorno POSTGRES_PASSWORD del sistema y la guarda en la variable llamada pgpass,
-- basicamente para no escribir la contraseña en texto plano en el archivo
\set pgpass `echo "$POSTGRES_PASSWORD"`
-- crea un usuario que postgREST usa para conectarse a la base de datos, es el intermediario entre PostgREST y PostgreSQL,
-- tiene permiso de login porque necesita conectarse activamente
CREATE ROLE authenticator WITH LOGIN PASSWORD :'pgpass';
-- Crea el rol para usuarios no autenticados, cualquiera que acceda sin token JWT,
-- el NOINHERIT significa que no hereda automáticamente los permisos de otros roles,
-- los permisos hay que darselos explícitamente
CREATE ROLE anon NOINHERIT;
-- Crea el rol para usuarios registrados y autenticados,
-- los que tienen JWT válido. Tendrá más permisos que anon
CREATE ROLE web_user;
-- Le dice a PostgreSQL que authenticator puede actuar en nombre de anon y web_user.
-- Cuando llega una petición PostgREST entra como autenticator y 
-- luego cambia al rol correspondiente según el token JWT.
GRANT anon TO authenticator;
GRANT web_user TO authenticator;
