--Matias Vigo Munoz 
--Seccion 005D      
--Prueba 3          
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- USER: SYSTEM
----------------------


--CASO 01
--------------

--Primero creamos los tablespaces

CREATE TABLESPACE DAT_TURISM DATAFILE 'C:\app\inmat\product\18.0.0\oradata\TBS_ONE_TOUR\TBS_DATOS_01.DBF' SIZE 15M;
CREATE TABLESPACE IDX_TURISM DATAFILE 'C:\app\inmat\product\18.0.0\oradata\TBS_ONE_TOUR\TBS_IND_01.DBF' SIZE 5M;



--Creamos los users 

CREATE USER one_t_prueba3 IDENTIFIED BY prueba3
DEFAULT TABLESPACE DAT_TURISM
QUOTA 10M ON DAT_TURISM;

CREATE USER desarrollador_p3 IDENTIFIED BY desarrolladorp3
DEFAULT TABLESPACE DAT_TURISM
QUOTA 2M ON DAT_TURISM;



--Asignamos los privilegios al owner de prueba3

GRANT CONNECT, CREATE TABLE, ALTER TABLE, DROP ANY TABLE, CREATE SEQUENCE, CREATE SYNONYM, CREATE INDEXTYPE TO one_t_prueba3; 
-- 18c siempre presenta problemas con varias cosas, para crear usarios debo usar antes un alter session set "_ORACLE_SCRIPTS" 
-- Y los privilegios no deja asignarlos por separado muchas veces. También con el role resource no me deja leer scripts, siempre termino acudiendo al ALL PRIVILEGES
-- Esta vez lo haré así para efectos de seguir con la prueba.
GRANT ALL PRIVILEGES TO one_t_prueba3;



--Asignamos los privilegios al desarrollador

CREATE ROLE rol_desarrollo;

--System privileges
GRANT CONNECT, CREATE ANY VIEW, CREATE SYNONYM TO rol_desarrollo;

--Objects privileges
GRANT INSERT, SELECT, UPDATE, DELETE ON one_t_prueba3.agencia TO rol_desarrollo;
GRANT INSERT, SELECT, UPDATE, DELETE ON one_t_prueba3.procedencia TO rol_desarrollo;
GRANT INSERT, SELECT, UPDATE, DELETE ON one_t_prueba3.cliente TO rol_desarrollo;

GRANT rol_desarrollo TO desarrollador_p3;

--Creamos public synonyms to ocultar los nombres reales de las tablas a las que puede acceder el user desarrollador_p3
CREATE PUBLIC SYNONYM TABLA_AGE FOR one_t_prueba3.agencia;
CREATE PUBLIC SYNONYM TABLA_PRO FOR one_t_prueba3.procedencia;
CREATE PUBLIC SYNONYM TABLA_CLI FOR one_t_prueba3.cliente;



--Creamos los tres users consultores

CREATE USER consultor_1 IDENTIFIED BY consultor1 DEFAULT TABLESPACE DAT_TURISM QUOTA 1M ON DAT_TURISM;
CREATE USER consultor_2 IDENTIFIED BY consultor2 DEFAULT TABLESPACE DAT_TURISM QUOTA 1M ON DAT_TURISM;
CREATE USER consultor_3 IDENTIFIED BY consultor3 DEFAULT TABLESPACE DAT_TURISM QUOTA 1M ON DAT_TURISM;

--Creamos un rol con los privilegios que corresponden a estos consultores
CREATE ROLE consultores;
GRANT CONNECT, CREATE SESSION TO consultores; -- System privileges
GRANT SELECT ON one_t_prueba3.habitacion TO consultores; -- Object privilege (read)
GRANT SELECT ON one_t_prueba3.reserva TO consultores; -- Object privilege (read)
GRANT SELECT ON one_t_prueba3.cliente_tour TO consultores; --Object privilege (read)

--Asignamos el rol a los consultores
GRANT consultores TO consultor_1;
GRANT consultores TO consultor_2;
GRANT consultores TO consultor_3;

--Creamos los synonyms respectivos
CREATE PUBLIC SYNONYM TABLA_HAB FOR one_t_prueba3.habitacion;
CREATE PUBLIC SYNONYM TABLA_RES FOR one_t_prueba3.reserva;
CREATE PUBLIC SYNONYM TABLA_CLT FOR one_t_prueba3.cliente_tour;



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- USER: desarrollador_p3
--------------------------------


--CASO 02
--------------


--Preparo mi query
SELECT a.nom_agencia AS "AGENCIA",
       COUNT(c.id_cliente) AS "CLIENTES POR AGENCIA"
FROM tabla_age A JOIN tabla_cli C
ON(a.id_agenc = c.id_agencia)
GROUP BY a.id_agenc, a.nom_agencia
HAVING COUNT(c.id_cliente) < (
                                SELECT MIN(COUNT(c.id_cliente)) AS "CLIENTES POR AGENCIA"
                                FROM tabla_age A JOIN tabla_cli C
                                ON(a.id_agenc = c.id_agencia)
                                WHERE UPPER(a.nom_agencia) IN ('VIAJES EL SOL', 'TRAVEL EL SOL')
                                GROUP BY a.id_agenc, a.nom_agencia
                             );

--La almaceno en una vista
CREATE OR REPLACE VIEW ONE_T_PRUEBA3.V_CLIENTES_POR_AGENCIA AS
SELECT a.nom_agencia AS "AGENCIA",
       COUNT(c.id_cliente) AS "CLIENTES POR AGENCIA"
FROM tabla_age A JOIN tabla_cli C
ON(a.id_agenc = c.id_agencia)
--WHERE EXTRACT(YEAR FROM ALGUNA_FECHA) = EXTRACT(YEAR FROM SYSDATE) -1
GROUP BY a.id_agenc, a.nom_agencia
HAVING COUNT(c.id_cliente) < (
                                SELECT MIN(COUNT(c.id_cliente)) AS "CLIENTES POR AGENCIA"
                                FROM tabla_age A JOIN tabla_cli C
                                ON(a.id_agenc = c.id_agencia)
                                WHERE UPPER(a.nom_agencia) IN ('VIAJES EL SOL', 'TRAVEL EL SOL')
                                GROUP BY a.id_agenc, a.nom_agencia
                             )
ORDER BY 2 desc
WITH READ ONLY;


-------------------------------------------------------------------------------------------------------

-- USER: one_t_prueba3
--------------------------

SELECT * FROM v_clientes_por_agencia;


-------------------------------------------------------------------------------------------------------

-- USER: SYSTEM
---------------------

GRANT SELECT ON ONE_T_PRUEBA3.V_CLIENTES_POR_AGENCIA TO rol_desarrollo;

GRANT rol_desarrollo TO desarrollador_p3;

-------------------------------------------------------------------------------------------------------


------DESARROLLO


----1

--Generar la información de aquellas agencias que el año anterior tuvieron una cantidad de clientes 
--por debajo de la agencia que tuvo menor cantidad de clientes entre viajes sol y travel sol.
--Sí me dejó crear la vista, pues el role rol_desarrollo contiene el create any view.


----2

-- Una alternativa podría ser crear otra view que almacene la subquery 
--          HAVING COUNT(c.id_cliente) < (
--                                         SELECT MIN(COUNT(c.id_cliente)) AS "CLIENTES POR AGENCIA"
--                                         FROM tabla_age A JOIN tabla_cli C
--                                         ON(a.id_agenc = c.id_agencia)
--                                         WHERE UPPER(a.nom_agencia) IN ('VIAJES EL SOL', 'TRAVEL EL SOL')
--                                         GROUP BY a.id_agenc, a.nom_agencia
--                                       )
-- Y Luego citar esa view dentro de la view V_CLIENTES_POR_AGENCIA quedando algo así por ejemplo

--               CREATE OR REPLACE VIEW ONE_T_PRUEBA3.V_CLIENTES_POR_AGENCIA AS
--               SELECT a.nom_agencia AS "AGENCIA",
--                      COUNT(c.id_cliente) AS "CLIENTES POR AGENCIA"
--               FROM tabla_age A JOIN tabla_cli C
--               ON(a.id_agenc = c.id_agencia)
--               GROUP BY a.id_agenc, a.nom_agencia
--               HAVING COUNT(c.id_cliente) < (
--                                               SELECT "CLIENTES POR AGENCIA"  FROM ONE_T_PRUEBA3.v_subquery
--                                            )
--               ORDER BY 2 desc

	

-----3

-- La ventaja que tendríamos sería poder a la info de la subquery de manera anterior e independiente de la query-vista general. 
-- Una desventaja sería que se particiona el storage, lo que sospecho puede traer complicaciones insospechada.




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- USER: one_t_prueba3 (owner)
------------------------------------

--CASO 03

SELECT cl.nom_cliente ||' '|| cl.appat_cliente AS NOMBRE_CLIENTE,
       r.estadia AS DIAS_ALOJAMIENTO,
       ROUND(c.monto*815) AS MONTO_EN_pesos
FROM CONSUMO C JOIN CLIENTE CL
ON(c.id_cliente = cl.id_cliente)
JOIN RESERVA R
ON(r.id_cliente = cl.id_cliente)
WHERE ROUND(c.monto*815) > 200000;

CREATE INDEX IDX_CONSUMO_MONTO ON CONSUMO (ROUND(monto*815))
TABLESPACE IDX_TURISM;

CREATE INDEX IDX_RESERVA ON RESERVA (id_cliente)
TABLESPACE IDX_TURISM;

-- Los indexes fueron creados en el TABLESPACE IDX_TURISM DATAFILE 'TBS_IND_01.DBF' sin problema ya que el owner tiene el privilege to create indexes.

