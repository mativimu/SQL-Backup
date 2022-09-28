--GUIA 01
--MATIAS VIGO MUÑOZ
-------------------------

-- CASO1 GUI01
SELECT 'El empleado '|| nombre_emp ||' '|| appaterno_emp ||' '|| apmaterno_emp ||' nació el '||to_char(fecnac_emp, 'DD/MM/YYYY')
AS "LISTADO DE CUMPLEAÑOS"
FROM empleado
ORDER BY fecnac_emp, appaterno_emp;



-- CASO2 GUIA01
SELECT numrut_cli AS "NUMERO RUT",
       dvrut_cli AS "DIGITO VERIFICADOR",
       appaterno_cli || ' ' || apmaterno_cli ||' '|| nombre_cli AS "NOMBRE CLIENTE",
       renta_cli AS "RENTA",
       fonofijo_cli AS "TELEFONO FIJO",
       NVL(to_char(celular_cli), ' ') AS "CELULAR"
       
FROM cliente
ORDER BY appaterno_cli, apmaterno_cli;



--CASO3 GUIA01
SELECT nombre_emp ||' '|| appaterno_emp ||' '|| apmaterno_emp AS "NOMBRE EMPLEADO",
       sueldo_emp AS "SUELDO",
       (sueldo_emp * 0.5) AS "BONO POR CAPACITACION"
FROM empleado
ORDER BY 3 desc;



--CASO4 GUIA01
SELECT nro_propiedad AS "NRO PROPIEDAD",
       numrut_prop AS "RUT PROPIETARIO",
       direccion_propiedad AS "DIRECCION PROPIEDAD",
       valor_arriendo AS "VALOR ARRIENDO",
       (valor_arriendo*0.054) AS "VALOR COMPENSACION"
       
FROM propiedad
ORDER BY 2;



--CASO5 GUIA01
SELECT numrut_emp||'-'||dvrut_emp AS "RUN EMPLEADO",
       nombre_emp||' '||appaterno_emp||' '||apmaterno_emp AS "NOMBRE EMPLEADO",
       sueldo_emp AS "SALARIO ACTUAL",
       round(sueldo_emp * 1.135) AS "SALARIO REAJUSTADO",
       round(sueldo_emp * .135) AS "REAJUSTE"
       
FROM empleado
ORDER BY 5, appaterno_emp;



--CASO6 GUIA01
SELECT nombre_emp||' '||appaterno_emp||' '||apmaterno_emp AS "NOMBRE EMPLEADO",
       sueldo_emp AS "SALARIO",
       sueldo_emp * .055 AS "COLACION",
       sueldo_emp * .178 AS "MOVILIZACION",
       sueldo_emp * .078 AS "SALUD",
       sueldo_emp * .065 AS "AFP",
       (sueldo_emp + sueldo_emp * .055 + sueldo_emp * .178 - sueldo_emp * .078 - sueldo_emp * .065) AS "ALACANCE LIQUIDO"

FROM empleado
ORDER BY appaterno_emp;

