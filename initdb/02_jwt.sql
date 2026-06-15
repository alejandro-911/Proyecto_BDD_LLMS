-- comando de psql (noSQL) que lee las variables de entorno JWT_SECRET y JWT_EXP del sistema
-- (las que están definidas en el docker-compose) y las guarda en variables de psql para usarlas después 
\set jwt_secret `echo "$JWT_SECRET"`
\set jwt_exp `echo "$JWT_EXP"`
-- Guarda esos valores dentro de la propia base de datos como configuración global.
-- Así cualquier función SQL puede leerlos después con current_setting('app.settings.jwt_secret')
ALTER DATABASE postgres SET app.settings.jwt_secret = :'jwt_secret';
ALTER DATABASE postgres SET app.settings.jwt_exp = :'jwt_exp';
--los ALTER DATABASE guardan esos valores dentro de la própia BDD como configuración global
-- comom meter las varibales de entorno dentro de postgreSQL
-- asi: funciones SQL pueden usarlas (login para firmar el token)

/*
docker-compose.yml define JWT_SECRET y JWT_EXP
        ↓
02_jwt.sql los lee y los mete dentro de PostgreSQL
        ↓
login() los lee con current_setting() para firmar el token
*/
