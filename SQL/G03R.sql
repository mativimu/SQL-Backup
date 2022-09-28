--GUIA 03
--MATIAS VIGO MUÑOZ
-------------------------


--CASO1 GUIA03

SELECT SUBSTR(rutemp, 1, LENGTH(rutemp)-1) ||'-'|| SUBSTR(rutemp, -1) AS "RUN EMPLEADO",
       paterno ||' '|| materno ||' '|| nombre AS "NOMBRE",
       direccion AS "DIRECCION",
       NVL(to_char(fono1), 'NO POSEE FONO') AS "FONO 1",
       NVL(to_char(fono2), 'NO POSEE FONO') AS "FONO 2"
FROM empleado
ORDER BY nombre;


--CASO2 GUIA03

SELECT SUBSTR(rutemp, 1, LENGTH(rutemp)-1) ||'-'|| SUBSTR(rutemp, -1) AS "RUN EMPLEAO",
       sueldo AS "SUELDO",
       to_char(round(sueldo/100000))||'%' AS PORCENTAJE
FROM empleado
WHERE idcategoria = 2;


--CASO3 GUIA03

SELECT paterno ||' '|| materno ||' '|| nombre AS "EMPLEADO",
       LOWER(SUBSTR(nombre, 1, 2))||'.'||paterno AS "USUARIO",
       LOWER(SUBSTR(ecivil, 1, 1))||'*'||SUBSTR(to_char(rutemp), 1, 4)||SUBSTR(LOWER(direccion), 1, 1)||'-'||SUBSTR(UPPER(direccion), 2, 1) AS "CONTRASEÑA"
FROM empleado
ORDER BY 2;


--CASO4 GUIA03

SELECT SUBSTR(rutemp, 1, LENGTH(rutemp)-1)||'-'||SUBSTR(rutemp, -1) AS "RUN EMPLEADO", 
       paterno ||' '|| materno ||' '|| nombre AS "EMPLEADO",
       sueldo AS "SUELDO",
       ROUND(CASE
            WHEN puntaje > 100 and puntaje <= 300 THEN sueldo* 1.15
            WHEN puntaje > 300 and puntaje <= 500 THEN sueldo* 1.25
            WHEN puntaje > 500 THEN sueldo * 1.035
            ELSE sueldo
       END) AS "SUELDO AUMENTADO"
FROM empleado
ORDER BY paterno;


--CASO5 GUIA03

SELECT numpropiedad AS "NUMERO DE PROPIEDAD",
       idtipo AS "TIPO",
       NVL(renta, 0) AS "RENTA",
       NVL(gastocomun, 0) AS "GASTOS COMUNES",
       NVL(round(renta * 1.062), 0) AS "NUEVA RENTA",
       NVL(round(gastocomun * 1.062), 0) AS "GASTO COMUN REAJUSTADO"
FROM propiedad
ORDER BY numpropiedad;


--CASO6 GUIA03

SELECT SUBSTR(rutcli, 1, LENGTH(rutcli) -1)||'-'||SUBSTR(rutcli, -1) AS "RUT",
       nomcli AS "NOMBRE",
       direccion AS "DIRECCION",
       NVL(to_char(fono1), 'NO REGISTRA') AS "FONO CLIENTE",
       NVL(to_char(fono2), 'NO REGISTRA') AS "CELULAR"
FROM cliente
WHERE lower(ecivil) = 'soltero' and idtipo = 'B'
ORDER BY nomcli desc;