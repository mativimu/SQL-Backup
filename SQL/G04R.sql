--GUIA 04
--MATIAS VIGO MUÑOZ
-------------------------


--CASO1 GUIA04

SELECT to_char(numrun_cli, '99G999G999')||'-'||dvrun_cli AS "RUN CLIENTE",
       INITCAP(lower(appaterno_cli))||' '||SUBSTR(upper(apmaterno_cli), 1, 1)||'. '||INITCAP(lower(pnombre_cli))||' '||INITCAP(lower(snombre_cli)) AS "NOMBRE CLIENTE",
       direccion AS "DIRECCION",
       NVL(to_char(fono_fijo_cli), 'NO POSEE TELEFONO FIJO') AS "TELEFONO FIJO",
       NVL(to_char(celular_cli), 'NO POSEE CELULAR') AS "CELULAR",
       id_comuna AS "COMUNA"
FROM cliente
ORDER BY id_comuna, appaterno_cli desc;





--CASO2 GUIA04

SELECT 'El empleado '||pnombre_emp||' '||appaterno_emp||' '||apmaterno_emp||' estuvo de cumpleaños el '
       ||to_char(fecha_nac, 'dd "de" month')||'. Cumplió '||(EXTRACT(year from sysdate)- EXTRACT(year from fecha_nac))
       AS "LISTADO DE CUMPLEAÑOS"
FROM empleado
WHERE EXTRACT( month from fecha_nac) = EXTRACT(month from ADD_MONTHS(sysdate, -1))
ORDER BY EXTRACT( day from fecha_nac), appaterno_emp;





--CASO3 GUIA04

SELECT CASE
            WHEN id_tipo_camion = 'A' THEN 'Tradicional 6 toneladas'
            WHEN id_tipo_camion = 'B' THEN 'Frigorífico'
            WHEN id_tipo_camion = 'C' THEN 'Camión 3/4'
            WHEN id_tipo_camion = 'D' THEN 'Trailer'
            WHEN id_tipo_camion = 'A' THEN 'Tolva'
        ELSE 'N/A'
        END AS  "TIPO CAMION",
       nro_patente AS "NRO PATENTE",
       anio AS "AÑO",
       to_char(NVL(valor_arriendo_dia, 0), '$9G999G999') AS "VALOR ARRIENDO DIA",
       to_char(NVL(valor_garantia_dia, 0), '999G999') AS "VALOR GARANTIA DIA",
       to_char((valor_arriendo_dia + NVL(valor_garantia_dia, 0)), '$99G999G999') AS "VALOR TOTAL DIA"
       
FROM camion
ORDER BY 1, valor_arriendo_dia desc, NVL(valor_garantia_dia, 0), nro_patente;





--CASO4 GUIA04

SELECT to_char(sysdate, 'MM/YYYY') AS "FECHA PROCESO",
       to_char(numrun_emp , '99G999G999') ||'-'|| dvrun_emp AS "RUN EMPLEADO",
       pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp AS "NOMBRE EMPLEADO",
       to_char(sueldo_base, '$9G999G999') AS "SUELDO BASE",
       to_char(round(CASE
            WHEN sueldo_base >= 320000 and sueldo_base < 450000 THEN .005
            WHEN sueldo_base >= 450000 and sueldo_base < 600000 THEN .0035
            WHEN sueldo_base >= 600000 and sueldo_base < 900000 THEN .0025
            WHEN sueldo_base >= 900000 and sueldo_base < 1800000 THEN .0015
            ELSE 0.001
       END * &utilidades), '$9G999G999') AS "BONIFICACION POR UTILIDADES"
FROM empleado
ORDER BY appaterno_emp;





--CASO5 GUIA05

SELECT numrun_emp||'-'||dvrun_emp AS "RUN EMPLEADO",
       pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp AS "NOMBRE EMPLEADO",
       (EXTRACT(year from sysdate) - EXTRACT(year FROM fecha_contrato))-1 AS "AÑOS CONTRATADO",
       to_char(sueldo_base, '$9G999G999') AS "SUELDO BASE",
       to_char(round((((EXTRACT(year from sysdate) - EXTRACT(year from fecha_contrato)) -1)/100)* sueldo_base), '$9G999G999') AS "VALOR MOVILIZACION",
       to_char(round(
       CASE
            WHEN sueldo_base < 450000 THEN to_number(SUBSTR(sueldo_base, 1, 2))
       ELSE to_number(SUBSTR(to_char(sueldo_base), 1, 1))
       END/100 *sueldo_base), '$9G999G999') AS "BONO EXTRA MOVILIZACION",
       
       to_char(
       round((((EXTRACT(year from sysdate) - EXTRACT(year from fecha_contrato)) -1)/100)* sueldo_base) +
       round(
       CASE
            WHEN sueldo_base < 450000 THEN to_number(SUBSTR(to_char(sueldo_base), 1, 2))
       ELSE to_number(SUBSTR(sueldo_base, 1, 1))
       END /100 * sueldo_base), '$9G999G999') AS "VALOR MOVILIZACION TOTAL"
FROM empleado
WHERE id_comuna in (117, 118, 120, 122, 126)
ORDER BY appaterno_emp;





--CASO6 GUIA04

SELECT 
       EXTRACT(year from sysdate) AS "AÑO TRIBUTARIO",

       numrun_emp||'-'||dvrun_emp AS "RUN EMPLEADO",

       pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp AS "NOMBRE EMPLEADO",
       
       EXTRACT(month from sysdate) AS "MESES TRABAJADOS",
       
       (EXTRACT(year from sysdate) - EXTRACT(year FROM fecha_contrato)) AS "AÑOS TRABAJADOS",
       
       to_char(sueldo_base, '$9G999G999') AS "SUELDO BASE MENSUAL",
       
       to_char(sueldo_base*12, '$999G999G999') AS "SUELDO BASE ANUAL",
       
       to_char(CASE
            WHEN (EXTRACT(year from sysdate) - EXTRACT(year FROM fecha_contrato)) >= 1 THEN round( ((EXTRACT(year from sysdate) - EXTRACT(year FROM fecha_contrato))/100) * sueldo_base)
       ELSE 0
       END * 12, '$999G999G999') AS "BONO POR AÑOS ANUAL",
       
       to_char(round((sueldo_base * .12) * 12), '$999G999G999') AS "MOVILIZACION ANUAL",
       
       to_char(round((sueldo_base * .2) * 12), '$999G999G999') AS "COLACION ANUAL",
       
       to_char((round(sueldo_base + (sueldo_base * .12) + (sueldo_base * .2) +
       CASE
            WHEN (EXTRACT(year from sysdate) - EXTRACT(year FROM fecha_contrato)) >= 1 THEN round( ((EXTRACT(year from sysdate) - EXTRACT(year FROM fecha_contrato))/100) * sueldo_base)
       ELSE 0
       END))*12, '$999G999G999') AS "SUELDO BRUTO ANUAL",
       
       to_char((round(sueldo_base +
       CASE
            WHEN (EXTRACT(year from sysdate) - EXTRACT(year FROM fecha_contrato)) >= 1 THEN round( ((EXTRACT(year from sysdate) - EXTRACT(year FROM fecha_contrato))/100) * sueldo_base)
       ELSE 0
       END))*12, '$999G999G999') AS "RENTA IMPONIBLE ANUAL"
       
FROM empleado
ORDER BY 2;