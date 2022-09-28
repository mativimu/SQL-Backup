--GUIA 05
--MATIAS VIGO MUÑOZ
-------------------------


----CASO1 GUIA05

SELECT carreraid AS "IDENTIFICACION DE LA CARRERA",
       COUNT(carreraid) AS "TOTAL ALUMNOS MATRICULADOS", -- Con el group by, el count() cuenta por grupo
       'Le corresponden $' || COUNT(carreraid)*&Ingrese_monto || ' del presupuesto total designado para publicidad' AS "MONTO POR PUBLICIDAD"
FROM alumno
GROUP BY carreraid
ORDER BY 2 desc, 1;



----CASO2 GUIA05

SELECT carreraid AS "CARRERA",
       COUNT(carreraid) AS "TOTAL ALUMNOS"
       
FROM alumno
GROUP BY carreraid
HAVING COUNT(carreraid) > 4
ORDER BY 1;



----CASO3 GUIA05

SELECT to_char(run_jefe, '99G999G999') AS "RUN JEFE SIN DV",
       COUNT(to_char(run_jefe, '99G999G999')) AS "TOTAL DE EMPLEADOS A SU CARGO",
       to_char(MAX(salario), '99G999G999') AS "SALARIO MÁXIMO",
       COUNT(to_char(run_jefe, '99G999G999')) *10 || '% del salario máximo' AS "PORCENTAJE DE BONIFICACION",
       to_char(MAX(salario) * (COUNT(to_char(run_jefe, '99G999G999')) / 10), '$99G999G999') AS "BONIFICACION"
FROM empleado
WHERE run_jefe IS NOT NULL
GROUP BY to_char(run_jefe, '99G999G999')
ORDER BY 2;



----CASO4 GUIA05

SELECT id_escolaridad AS "ESCOLARIDAD",
       CASE id_escolaridad
            WHEN 10 THEN 'BASICA'
            WHEN 20 THEN 'MEDIA CIENTIFICA HUMANISTA'
            WHEN 30 THEN 'MEDIA TECNICO PROFESIONAL'
            WHEN 40 THEN 'SUPERIOR CENTRO DE FORMACION TECNICA'
            WHEN 50 THEN 'SUPERIOR INSTITUTO PROFESIONAL'
            WHEN 60 THEN 'SUPERIOR UNIVERSIDAD'
       ELSE 'NO APLICA'
       END AS "DESCRIPCION ESCOLARIDAD",
       COUNT(id_escolaridad) AS "TOTAL EMPLEADO",
       to_char(MAX(salario), '$999G999G999') AS "SALARIO MAXIMO",
       to_char(MIN(salario), '$999G999G999') AS "SALARIO MINIMO",
       to_char(SUM(salario), '$999G999G999') AS "SALARIO TOTAL",
       to_char(ROUND(AVG(salario)), '$999G999G999') AS "SALARIO"
       
FROM empleado
GROUP BY id_escolaridad,
         CASE id_escolaridad 
                WHEN 10 THEN 'BASICA' 
                WHEN 20 THEN 'MEDIA CIENTIFICA HUMANISTA' 
                WHEN 30 THEN 'MEDIA TECNICO PROFESIONAL' 
                WHEN 40 THEN 'SUPERIOR CENTRO DE FORMACION TECNICA' 
                WHEN 50 THEN 'SUPERIOR INSTITUTO PROFESIONAL' 
                WHEN 60 THEN 'SUPERIOR UNIVERSIDAD' 
         ELSE 'NO APLICA' 
         END
ORDER BY 3 DESC;



----CASO5 GUIA05


SELECT tituloid AS "CODIGO DEL LIBRO",
       COUNT(tituloid) AS "TOTAL DE VECES SOLICITADO",
       CASE 
            WHEN COUNT(tituloid) = 1 THEN 'No se requiere comprar nuevos ejemplares'
            WHEN COUNT(tituloid) IN (2,3) THEN 'Se requiere comprar 1 nuevos ejemplares'
            WHEN COUNT(tituloid) IN (4,5) THEN 'Se requiere comprar 2 nuevos ejemplares'
       ELSE 'Se requiere comprar 4 nuevos ejemplares'
       END AS "       SUGERENCIA"
FROM prestamo
WHERE EXTRACT(year FROM sysdate) - 1 = EXTRACT(year FROM fecha_ini_prestamo)
GROUP BY tituloid
ORDER BY 2 desc;


----CASO6 GUIA05

SELECT to_char(run_emp, '09G999G999') AS "RUN EMPLEADO",
       to_char(fecha_ini_prestamo, 'MM/YYYY') AS "MES PRESTAMO LIBROS",
       COUNT(to_char(run_emp, '09G999G999')) AS "TOTAL PRESTAMOS ATENDIDOS",
       to_char(10000*COUNT(to_char(run_emp, '09G999G999')), '$999G999') AS "ASIGANCIÓN POR PRESTAMOS"
FROM prestamo
WHERE &anno - 1  = EXTRACT(YEAR FROM fecha_ini_prestamo)
GROUP BY to_char(run_emp, '09G999G999'), to_char(fecha_ini_prestamo, 'MM/YYYY')
ORDER BY 2, 4 desc, 1 desc;