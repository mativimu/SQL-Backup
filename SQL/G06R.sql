--GUIA 06
--MATIAS VIGO MUÑOZ
-------------------------



CASO1 GUIA06

SELECT to_char(c.numrun, '9G999G999G999')||'-'||c.dvrun AS "RUN CLIENTE",
       INITCAP(lower(c.pnombre ||' '|| c.snombre ||' '|| c.appaterno ||' '|| c.apmaterno))  AS "NOMBRE CLIENTE",
       p.nombre_prof_ofic AS "PROFESION/OFICIO",
       to_char(c.fecha_nacimiento, 'DD "de" Month') AS "DIA DE CUMPLEAÑOS"

FROM cliente C JOIN profesion_oficio P
ON (c.cod_prof_ofic = p.cod_prof_ofic)
WHERE EXTRACT(MONTH FROM c.fecha_nacimiento) = EXTRACT(MONTH FROM add_months(SYSDATE, 1))
ORDER BY 4, c.appaterno desc;



CASO2 GUIA06

SELECT to_char(c.numrun,'09G999G999')||'-'||c.dvrun AS "RUN CLIENTE",
       c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno AS "NOMBRE CLIENTE",
       to_char(cl.monto_solicitado,'$9G999G999G999') AS "MONTO SOLICITADO",
       to_char(trunc(cl.monto_solicitado / 100000) * 1200, '$999G999') AS "TOTAL PESOS TODOSUMA"
FROM cliente C left outer JOIN credito_cliente CL
ON (c.nro_cliente = cl.nro_cliente)
WHERE EXTRACT(year FROM cl.fecha_solic_cred) = EXTRACT(year FROM SYSDATE)-1
ORDER BY 4, c.appaterno;



CASO3 GUIA06

SELECT to_char(cc.fecha_otorga_cred, 'MMYYYY') AS "MES TRANSACCION",
       UPPER(c.nombre_credito) AS "TIPO CREDITO",
       SUM(cc.monto_credito) AS "MONTO SOLICITADO",
       ROUND(
       CASE
            WHEN SUM(cc.monto_credito) BETWEEN 100000 AND 1000000 THEN 0.01
            WHEN SUM(cc.monto_credito) BETWEEN 100001 AND 2000000 THEN 0.02
            WHEN SUM(cc.monto_credito) BETWEEN 200001 AND 4000000 THEN 0.03
            WHEN SUM(cc.monto_credito) BETWEEN 400001 AND 6000000 THEN 0.04
            ELSE 0.07
       END * SUM(cc.monto_credito) 
       ) AS "APORTE A LA SBIF"
FROM credito_cliente CC JOIN credito C
ON(cc.cod_credito = c.cod_credito)
WHERE EXTRACT(year FROM cc.fecha_otorga_cred) = EXTRACT(year FROM SYSDATE)-1
GROUP BY to_char(cc.fecha_otorga_cred, 'MMYYYY'), UPPER(c.nombre_credito)
ORDER BY 1, 2;



CASO4 GUIA06

SELECT to_char(c.numrun, '09G999G999')||'-'||c.dvrun AS "RUN CLIENTE",
       c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno AS "NOMBRE CLIENTE",
       LPAD(to_char(SUM(p.monto_total_ahorrado), '$9G999G999G999'), 21, ' ') AS "MONTO TOTAL AHORRADO",
       CASE
            WHEN SUM(p.monto_total_ahorrado) BETWEEN 100000 AND 1000000 THEN 'BRONCE'
            WHEN SUM(p.monto_total_ahorrado) BETWEEN 100001 AND 4000000 THEN 'PLATA'
            WHEN SUM(p.monto_total_ahorrado) BETWEEN 400001 AND 8000000 THEN 'SILVER'
            WHEN SUM(p.monto_total_ahorrado) BETWEEN 800001 AND 15000000 THEN 'GOLD'
            ELSE 'PLATINUM'
       END AS "CATEGORIA CLIENTE"
FROM cliente C JOIN producto_inversion_cliente P
ON (c.nro_cliente = p.nro_cliente)
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY c.appaterno, 3 desc;



CASO5 GUIA06

SELECT EXTRACT(YEAR FROM SYSDATE) AS "AÑO TRIBUTARIO",
       to_char(c.numrun, '09G999G999')||'-'||c.dvrun AS "RUN CLIENTE",
       INITCAP(lower(c.pnombre||' '||SUBSTR(c.snombre, 1, 1)||'. '||c.appaterno||' '||c.apmaterno)) AS "NOMBRE CLIENTE",
       COUNT(pc.cod_prod_inv) AS "TOTAL PROD. INV. AFECTOS A IMP.",
       LPAD(to_char(SUM(pc.monto_total_ahorrado), '$999G999G999'), 21, ' ') AS "MONTO TOTAL AHORRADO"
       
FROM cliente C JOIN producto_inversion_cliente PC
ON (c.nro_cliente = pc.nro_cliente)
WHERE pc.cod_prod_inv IN (30,35,40,45,50,55)
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY c.appaterno;



CASO6 GUIA06

informe1
SELECT to_char(c.numrun, '09G999G999')||'-'||c.dvrun AS "RUN CLIENTE",
       INITCAP(lower(c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno)) AS "NOMBRE CLIENTE",
       COUNT(c.nro_cliente) AS "TOTAL CREDITOS SOLICITADOS",
       LPAD(to_char(SUM(cl.monto_credito), '$999G999G999'), 21) AS "MONTO TOTAL CREDITOS"
       
FROM cliente C JOIN credito_cliente CL
ON(c.nro_cliente = cl.nro_cliente)
WHERE EXTRACT(YEAR FROM cl.fecha_solic_cred) = &annio
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY c.appaterno;

informe2
SELECT to_char(c.numrun, '09G999G999')||'-'||c.dvrun AS "RUN CLIENTE",
       INITCAP(lower(c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno)) AS "NOMBRE CLIENTE",
       CASE m.cod_tipo_mov
            WHEN 1 THEN to_char(SUM(m.monto_movimiento), '$999G999G999')
            ELSE '   No realizó'
       END AS "ABONO",
       CASE m.cod_tipo_mov
            WHEN 2 THEN to_char(SUM(m.monto_movimiento), '$999G999G999')
            ELSE '   No realizó'
       END AS "RESCATE"
       --.........(Hice lo que pude con los conocimientos que tengo hasta el momento)
FROM cliente C JOIN movimiento M
ON(c.nro_cliente = m.nro_cliente)
WHERE EXTRACT(YEAR FROM m.fecha_movimiento) = &annio
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno, m.cod_tipo_mov
ORDER BY c.appaterno;