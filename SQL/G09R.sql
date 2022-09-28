--GUIA 08
--MATIAS VIGO MUÑOZ
-------------------------



CASO1 GUIA08

SELECT CASE
            WHEN pl.dvrun_prof IN ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z') THEN to_char(pl.numrun_prof, '9G909G999G999')||'-K'
            ELSE to_char(pl.numrun_prof, '9G909G999G999')||'-'||pl.dvrun_prof
       END AS "RUN PROFESIONAL",
       INITCAP(TRIM(pl.appaterno)||' '||TRIM(pl.apmaterno)||' '||TRIM(pl.nombre)) AS "NOMBRE PROFESIONAL",
       p.nombre_profesion AS "PROFESION"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE pl.numrun_prof IN (
                            SELECT numrun_prof
                            FROM profesional
                            WHERE cod_profesion IN (5,6)
                            MINUS
                            SELECT numrun_prof
                            FROM otros_profesionales
                            WHERE cod_profesion IN (5,6)
                        )
ORDER BY 1;

-----------------------------------------------------------------------------

CASO2 GUIA08

SELECT CASE
            WHEN pl.dvrun_prof IN ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z') THEN to_char(pl.numrun_prof, '9G909G999G999')||' K'
            ELSE to_char(pl.numrun_prof, '9G909G999G999')||' '||pl.dvrun_prof
       END AS "RUN PROFESIONAL",
       INITCAP(TRIM(pl.nombre)||' '||TRIM(pl.appaterno)||' '||TRIM(pl.apmaterno)) AS "NOMBRE PROFESIONAL",
       p.nombre_profesion AS "PROFESION"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE pl.numrun_prof IN (
                            SELECT numrun_prof
                            FROM contador_auditor
                            INTERSECT
                            SELECT numrun_prof
                            FROM contador_general
                        );

-----------------------------------------------------------------------------

CASO3 GUIA 08

SELECT CASE
            WHEN pl.dvrun_prof IN ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z') THEN to_char(pl.numrun_prof, '9G909G999G999')||' K'
            ELSE to_char(pl.numrun_prof, '9G909G999G999')||' '||pl.dvrun_prof
       END AS "RUN PROFESIONAL",
       INITCAP(TRIM(pl.nombre)||' '||TRIM(pl.appaterno)||' '||TRIM(pl.apmaterno)) AS "NOMBRE PROFESIONAL",
       p.nombre_profesion AS "PROFESION"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE pl.numrun_prof IN (
                            SELECT numrun_prof
                            FROM profesional
                            WHERE cod_profesion = 4
                            INTERSECT
                            SELECT numrun_prof
                            FROM otros_profesionales
                            WHERE cod_profesion = 4
                        )
ORDER BY 1;

------------------------------------------------------------------------------

CASO4 GUIA08

4.1
SELECT 'TABLA NUEVA',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM contador_general G JOIN profesional PL
ON(g.numrun_prof = pl.numrun_prof and g.cod_profesion = 2)
JOIN profesion P
ON(p.cod_profesion = pl.cod_profesion)
GROUP BY p.nombre_profesion
UNION
SELECT 'TABLA ORIGINAL',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE p.cod_profesion = 2
GROUP BY p.nombre_profesion;

4.2
SELECT 'TABLA NUEVA',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM contador_auditor A JOIN profesional PL
ON(a.numrun_prof = pl.numrun_prof and a.cod_profesion = 1)
JOIN profesion P
ON(p.cod_profesion = pl.cod_profesion)
GROUP BY p.nombre_profesion
UNION
SELECT 'TABLA ORIGINAL',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE p.cod_profesion = 1
GROUP BY p.nombre_profesion;

4.3
SELECT 'TABLA NUEVA',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM informatico I JOIN profesional PL
ON(i.numrun_prof = pl.numrun_prof and i.cod_profesion = 3)
JOIN profesion P
ON(p.cod_profesion = pl.cod_profesion)
GROUP BY p.nombre_profesion
UNION
SELECT 'TABLA ORIGINAL',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE p.cod_profesion = 3
GROUP BY p.nombre_profesion;

4.4
SELECT 'TABLA NUEVA',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM prevencionista PV JOIN profesional PL
ON(pv.numrun_prof = pl.numrun_prof and pv.cod_profesion = 4)
JOIN profesion P
ON(p.cod_profesion = pl.cod_profesion)
GROUP BY p.nombre_profesion
UNION
SELECT 'TABLA ORIGINAL',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE p.cod_profesion = 4
GROUP BY p.nombre_profesion;

4.5
SELECT 'TABLA NUEVA',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM otros_profesionales OP JOIN profesional PL
ON(op.numrun_prof = pl.numrun_prof and op.cod_profesion = 5)
JOIN profesion P
ON(p.cod_profesion = pl.cod_profesion)
GROUP BY p.nombre_profesion
UNION
SELECT 'TABLA ORIGINAL',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE p.cod_profesion = 5
GROUP BY p.nombre_profesion;

4.6
SELECT 'TABLA NUEVA',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM otros_profesionales OP JOIN profesional PL
ON(op.numrun_prof = pl.numrun_prof and op.cod_profesion = 6)
JOIN profesion P
ON(p.cod_profesion = pl.cod_profesion)
GROUP BY p.nombre_profesion
UNION
SELECT 'TABLA ORIGINAL',
       p.nombre_profesion AS "PROFESION",
       COUNT(p.nombre_profesion) AS "TOTAL EMPLEADOS"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE p.cod_profesion = 6
GROUP BY p.nombre_profesion;

-------------------------------------------------------------------------------

CASO5 GUIA08

SELECT CASE
            WHEN pl.dvrun_prof IN ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z') THEN to_char(pl.numrun_prof, '9G909G999G999')||' K'
            ELSE to_char(pl.numrun_prof, '9G909G999G999')||' '||pl.dvrun_prof
       END AS "RUN PROFESIONAL",
       INITCAP(TRIM(pl.nombre)) AS "NOMBRE",
       INITCAP(TRIM(pl.appaterno)) AS "APELLIDO PATERNO",
       INITCAP(TRIM(pl.apmaterno)) AS "APELLIDO MATERNO",
       p.nombre_profesion AS "PROFESION"
FROM profesion P JOIN profesional PL
ON(p.cod_profesion = pl.cod_profesion)
WHERE pl.numrun_prof IN (
                            SELECT numrun_prof
                            FROM profesional
                            WHERE cod_profesion IN (1,2)
                            MINUS
                            SELECT numrun_prof
                            FROM contador_auditor
                            WHERE cod_profesion = 1
                            MINUS
                            SELECT numrun_prof
                            FROM contador_general
                            WHERE cod_profesion = 2
                        )
ORDER BY 3, 4;