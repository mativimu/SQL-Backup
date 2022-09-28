--GUIA 02
--MATIAS VIGO MUÑOZ
-------------------------


--CASO1 GUIA02
--informe1
SELECT fecha_entrega_propiedad AS "FECHA ENTREGA PROPIEDAD"
FROM propiedad
WHERE extract(YEAR FROM fecha_entrega_propiedad) = &annio
ORDER BY extract(MONTH FROM fecha_entrega_propiedad);

--informe2
SELECT to_char(fecini_arriendo, 'DD/MM/YYYY') AS "FECHA INICIO ARRIENDO"
FROM propiedad_arrendada
WHERE extract(YEAR FROM fecini_arriendo) = &annio
ORDER BY extract(MONTH FROM fecini_arriendo);



--CASO2 GUIA02
SELECT numrut_cli||'-'||dvrut_cli AS "RUT CLIENTE",
       nombre_cli||' '||appaterno_cli||' '||apmaterno_cli AS "NOMBRE CLIENTE",
       renta_cli AS "RENTA",
       fonofijo_cli AS "TELEFONO FIJO",
       nvl(to_char(celular_cli), ' ') AS "CELULAR"
FROM cliente
--WHERE id_estcivil = 1 or id_estcivil = 3 and renta_cli >= 800000 or id_estcivil = 4 and renta_cli >=800000
WHERE id_estcivil in (3,4) and renta_cli >=800000 or id_estcivil = 1
ORDER BY appaterno_cli, nombre_cli;


--CASO3 GUIA02
SELECT nombre_emp||' '||appaterno_emp||' '||apmaterno_emp AS "NOMBRE EMPLEADO",
       sueldo_emp AS "SUELDO ACTUAL",
       sueldo_emp * (1 + :reajuste/100) AS "SUELDO REAJUSTADO",
       sueldo_emp * (1 + :reajuste/100) - sueldo_emp AS "AUMENTO"
FROM empleado
WHERE sueldo_emp >= &sueldo_base and sueldo_emp <= &sueldo_tope
--WHERE sueldo_emp BETWEEN &sueldo_base and &sueldo_tope
ORDER BY 4 desc;


--CASO4 GUIA02
SELECT numrut_emp ||'-'|| dvrut_emp AS "RUN EMPLEADO",
       nombre_emp ||' '|| apmaterno_emp ||' '|| apmaterno_emp AS "NOMBRE EMPLEADO",
       sueldo_emp AS "SALARIO ACTUAL",
       sueldo_emp * (&bonificacion/100) AS "BONIFICACION EXTRA"
FROM empleado
WHERE sueldo_emp < 500000 and id_categoria_emp in (1,2,4)
ORDER BY appaterno_emp;


--CASO5 GUIA02

--informe1
SELECT nro_propiedad AS "NUMERO DE PROPIEDAD",
       fecha_entrega_propiedad AS "FECHA ENTREGA PROPIEDAD",
       direccion_propiedad AS "DIRECCION",
       superficie AS "SUPERFICIE",
       nro_dormitorios AS "CANTIDAD DORMITORIOS",
       nro_banos AS "CANTIDAD DE BAÑOS",
       valor_arriendo AS "VALOR ARRIENDO"
FROM propiedad
WHERE extract(year FROM fecha_entrega_propiedad) = &annio
ORDER BY fecha_entrega_propiedad, nro_propiedad;


--informe2
SELECT nro_propiedad AS "NUMERO DE PROPIEDAD",
       fecha_entrega_propiedad AS "FECHA ENTREGA PROPIEDAD",
       direccion_propiedad AS "DIRECCION",
       superficie AS "SUPERFICIE",
       nro_dormitorios AS "CANTIDAD DORMITORIOS",
       nro_banos AS "CANTIDAD DE BAÑOS",
       valor_arriendo AS "VALOR ARRIENDO"
FROM propiedad
WHERE to_char(fecha_entrega_propiedad, 'MMYYYY') = '&annio'
ORDER BY fecha_entrega_propiedad, nro_propiedad;

--informe3
CREATE TABLE DET_PROPIEDADES_ARRIENDO_VENTA AS
SELECT nro_propiedad AS "NUMERO DE PROPIEDAD",
       fecha_entrega_propiedad AS "FECHA ENTREGA PROPIEDAD",
       direccion_propiedad AS "DIRECCION",
       superficie AS "SUPERFICIE",
       NVL(to_char(nro_dormitorios), ' ') AS "CANTIDAD DORMITORIOS",
       NVL(to_char(nro_banos), ' ') AS "CANTIDAD DE BAÑOS",
       valor_arriendo AS "VALOR ARRIENDO"
FROM propiedad
WHERE extract(year FROM fecha_entrega_propiedad) = &annio
ORDER BY fecha_entrega_propiedad, nro_propiedad;