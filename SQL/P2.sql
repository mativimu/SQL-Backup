MATÍAS VIGO MUÑOZ
PRUEBA 2
-----------------------------------------------------

--CASO1

CREATE TABLE RESUMEN_OCTUBRE_2020 AS
SELECT CASE 
            WHEN lower(SUBSTR(v.rutvendedor, -1)) IN ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')
            THEN to_char(SUBSTR(v.rutvendedor, 1, LENGTH(v.rutvendedor)-2), '99G999G999')||'-K'
            ELSE to_char(SUBSTR(v.rutvendedor, 1, LENGTH(v.rutvendedor)-2), '99G999G999')||'-'||SUBSTR(v.rutvendedor, -1)
       END AS "RUT EMPLEADO",
       UPPER(c.descripcion) AS "COMUNA",
       v.sueldo_base AS "SUELDO BASE",
       to_char(b.fecha, 'DD/MM/YYYY') AS "FECHA",
       to_char(r.porc_honorario, '0D00') AS "PORCENTAJE HONORARIOS",
       round(v.sueldo_base * r.porc_honorario) AS "BONIFICACION HONORARIOS",
       to_char(v.comision, '0D00') AS "COMISION",
       round(v.sueldo_base * v.comision) AS "BONIFICACION COMISION",
       to_char(round(v.sueldo_base * r.porc_honorario) + round(v.sueldo_base * v.comision), '$99G999G999') AS "TOTAL BONO"

FROM comuna C JOIN  vendedor V
ON(c.codcomuna = v.codcomuna)
JOIN boleta B
ON(
    v.rutvendedor = b.rutvendedor 
    and EXTRACT(month from b.fecha) = EXTRACT(month from add_months(sysdate, -1))
    and EXTRACT(year from b.fecha) = EXTRACT(year from add_months(sysdate, -1))
  )
JOIN rangos_sueldos R
ON(v.sueldo_base BETWEEN r.sueldo_min AND r.sueldo_max)
WHERE lower(c.descripcion) NOT LIKE '%vitacura%'
ORDER BY 2;


-- where alternativo
-- WHERE lower(c.descripcion) IN (
--                                    SELECT lower(descripcion)
--                                    FROM comuna
--                                    MINUS
--                                    SELECT lower(descripcion)
--                                    FROM comuna
--                                    WHERE lower(descripcion) LIKE '%vitacura%'
--                               )





--CASO 2


SELECT pa.nompais AS "PAIS",
       SUM(df.cantidad) AS "CANTIDAD",
       to_char(SUM(pr.vunitario), '$999G999G999') AS "PRECIO x UNIDAD"
FROM pais PA JOIN producto PR
ON (pa.codpais = pr.codpais)
LEFT JOIN promocion PM
ON(
    pr.codproducto = pm.codproducto and
    EXTRACT(year from pm.fecha_hasta) >= EXTRACT(year from sysdate) -1
  )
JOIN detalle_factura DF
ON(pr.codproducto = df.codproducto)
WHERE NVL(pm.codpromocion, 0) = 0 and pr.vunitario > 8000
GROUP BY pa.nompais
HAVING SUM(df.cantidad) >= (
                                SELECT round(AVG(SUM(NVL(f.cantidad, 0))))
                                FROM producto P LEFT JOIN detalle_factura F
                                ON(p.codproducto = f.codproducto)
                                GROUP BY p.codproducto
                            )
ORDER BY 2 desc ,3 desc;





--CASO3.1

INSERT INTO PAGO_VENDEDOR

SELECT to_char(b.fecha, 'MM YYYY') AS "PERIODO",
       CASE 
            WHEN lower(SUBSTR(v.rutvendedor, -1)) IN ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')
            THEN SUBSTR(v.rutvendedor, 1, LENGTH(v.rutvendedor)-2)||'-K'
            ELSE SUBSTR(v.rutvendedor, 1, LENGTH(v.rutvendedor)-2)||'-'||SUBSTR(v.rutvendedor, -1)
       END AS "RUT",
       UPPER(REPLACE(v.nombre, '  ', ' ')) AS "EMPLEADO",
       v.sueldo_base AS "SUELDO BASE",
       v.sueldo_base * v.comision AS "COMISION",
       round(SUM(b.total)*:reajuste* .05) AS "COLACION",
       round(SUM(b.total)*:reajuste* .08) AS "MOVILIZACION",
       round(SUM(b.total)*:reajuste* .10) AS "PREVISION",
       round(SUM(b.total)*:reajuste* .07) AS "SALUD",
       round(v.sueldo_base + SUM(b.total)*:reajuste* .05 + SUM(b.total)*:reajuste* .08 + SUM(b.total)*:reajuste* .10 + SUM(b.total)*:reajuste* .07) AS "TOTAL"
       
FROM vendedor V JOIN boleta B
ON(v.rutvendedor = b.rutvendedor)
WHERE EXTRACT(month from b.fecha) = EXTRACT(month from add_months(sysdate, -1))
      and EXTRACT(year from b.fecha) = EXTRACT(year from add_months(sysdate, -1))
GROUP BY v.rutvendedor, to_char(b.fecha, 'MM YYYY'), v.nombre, v.comision, v.sueldo_base
ORDER BY 3;

COMMIT;


1- El problema a resolver es el reajuste de los sueldos percibidos por los vendedores, en el periodo que corresponda y según los criterios señalados por gerencia.

2- Las entidades (vendedor y boleta) y los criterios para generar la nueva información (porcentajes y fórmulas)

3- Una alternativa sería poner la condición del where en la condición del JOIN, es decir, dentro del ON()

	FROM vendedor V JOIN boleta B
	ON(	v.rutvendedor = b.rutvendedor AND
		EXTRACT(month from b.fecha) = EXTRACT(month from add_months(sysdate, -1))
      		and EXTRACT(year from b.fecha) = EXTRACT(year from add_months(sysdate, -1))
	   )