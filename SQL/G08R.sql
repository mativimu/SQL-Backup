--GUIA 07
--MATIAS VIGO MUÑOZ
-------------------------




CASO1 GUIA07

SELECT u.nombre AS "UNIDAD",
       m.pnombre||' '||m.apaterno||' '||m.amaterno AS "MEDICO",
       SUBSTR(u.nombre, 1, 2)||SUBSTR(m.apaterno, LENGTH(m.apaterno)-2 , 2)||SUBSTR(to_char(m.telefono), 1, 3)||EXTRACT( YEAR FROM m.fecha_contrato)||'@medicocktk.cl' AS "CORREO ELECTRONICO",
       COUNT(a.ate_id) AS "ATENCIONES MEDICAS"
FROM unidad U JOIN medico M
ON(u.uni_id = m.uni_id)
JOIN especialidad_medico EM
ON(m.med_rut = em.med_rut)
JOIN atencion A
ON(em.med_rut = a.med_rut)
GROUP BY u.nombre, m.pnombre, m.apaterno, m.amaterno, m.telefono, m.fecha_contrato
HAVING COUNT(a.ate_id) < (
                            SELECT MAX(COUNT(ate_id))
                            FROM atencion
                            WHERE EXTRACT( YEAR FROM fecha_atencion) = EXTRACT(YEAR FROM SYSDATE)-1
                            GROUP BY med_rut
                          )
ORDER BY 1, m.apaterno;





CASO2 GUIA07

2.1
SELECT to_char(fecha_atencion, 'MM/YYYY') AS "MES Y AÑO",
       COUNT(ate_id) AS "TOTAL DE ATENCIONES",
       to_char(SUM(costo), '$9G999G999G999') AS "VALOR TOTAL DE LAS ATENCIONES"
FROM atencion
WHERE EXTRACT(year from fecha_atencion) = EXTRACT(year from sysdate)
GROUP BY to_char(fecha_atencion, 'MM/YYYY')
HAVING COUNT(ate_id) > (
                            SELECT round(AVG(COUNT(ate_id)))
                            FROM atencion
                            WHERE EXTRACT(year from fecha_atencion) = EXTRACT(year from sysdate)
                            GROUP BY to_char(fecha_atencion, 'MM/YYYY')
                       )

2.2
SELECT CASE
            WHEN p.dv_rut IN ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z') THEN p.pac_rut||'-K'
            ELSE p.pac_rut||'-'||p.dv_rut
       END AS "RUT PACIENTE",
       INITCAP(p.apaterno),
       a.ate_id AS "ID ATENCION",
       pa.fecha_venc_pago AS "FECHA VENCIMIENTO DE PAGO",
       pa.fecha_pago AS "FECHA DE PAGA",
       CASE 
            WHEN (EXTRACT(day from pa.fecha_pago) - EXTRACT(day from pa.fecha_venc_pago)) >= 0 THEN to_char((EXTRACT(day from pa.fecha_pago) - EXTRACT(day from pa.fecha_venc_pago)))
            ELSE 'PAGA ANTICIPADO'
            END AS "DIAS DE MOROSIDAD",
       CASE 
            WHEN (EXTRACT(day from pa.fecha_pago) - EXTRACT(day from pa.fecha_venc_pago)) >= 0 THEN to_char(2000*(EXTRACT(day from pa.fecha_pago) - EXTRACT(day from pa.fecha_venc_pago)))
            ELSE 'PAGA ANTICIPADO'
            END AS "MULTA"
FROM paciente P JOIN atencion A
ON(p.pac_rut = a.pac_rut)
JOIN pago_atencion PA
ON(
    a.ate_id = pa.ate_id and
    EXTRACT(year from pa.fecha_pago) = EXTRACT(year from sysdate)
  )
WHERE (EXTRACT(day from pa.fecha_pago) - EXTRACT(day from pa.fecha_venc_pago)) > (
                                                                                        SELECT round(AVG((EXTRACT(day from fecha_pago) - EXTRACT(day from fecha_venc_pago))))
                                                                                        FROM pago_atencion
                                                                                        WHERE EXTRACT(year from fecha_pago) = EXTRACT(year from sysdate) -1
                                                                                 )
ORDER BY 4, 6 desc;





CASO3 GUIA07

SELECT t.descripcion||','||s.descripcion AS "SISTEMA SALUD",
       COUNT(a.ate_id) AS "TOTAL ANTENCIONES"
FROM atencion A JOIN paciente P
ON( 
    p.pac_rut = a.pac_rut 
    and EXTRACT(MONTH FROM a.fecha_atencion) = EXTRACT(MONTH FROM add_months(sysdate, -1))
    and EXTRACT(YEAR FROM fecha_atencion) = EXTRACT (YEAR FROM sysdate)
  )
JOIN salud S
ON(p.sal_id = s.sal_id)
JOIN tipo_salud T
ON(s.tipo_sal_id = t.tipo_sal_id)
GROUP BY t.descripcion, s.descripcion
HAVING COUNT(a.ate_id) >
(
SELECT round(COUNT(ate_id)/ EXTRACT( day FROM last_day(add_months(sysdate,-1)) ))
FROM atencion
WHERE EXTRACT( MONTH FROM fecha_atencion ) = EXTRACT( MONTH FROM add_months(sysdate, -1)) and
EXTRACT( YEAR FROM fecha_atencion ) = EXTRACT ( YEAR FROM add_months(sysdate,-1))
)
ORDER BY 1;





CASO4 GUIA07

SELECT e.nombre AS "ESPECIALIDAD",
       CASE
            WHEN m.dv_rut IN ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z') THEN to_char(m.med_rut)||'-K'
            ELSE to_char(m.med_rut)||'-'||m.dv_rut
       END AS "RUT",
       UPPER(TRIM(m.pnombre)||' '||TRIM(m.snombre)||' '||TRIM(m.apaterno)||' '||TRIM(m.amaterno)) AS "MEDICO",
       COUNT(a.ate_id),
       EXTRACT(year from a.fecha_atencion)
FROM medico M JOIN especialidad_medico EM
ON(m.med_rut = em.med_rut)
LEFT JOIN atencion A
ON(em.esp_id = a.esp_id)
JOIN especialidad E
ON(e.esp_id = em.esp_id)
WHERE EXTRACT(year from a.fecha_atencion) = EXTRACT(year from sysdate) -1
GROUP BY em.esp_id, m.med_rut, m.dv_rut, e.nombre, m.pnombre, m.snombre, m.apaterno, m.amaterno, EXTRACT(year from a.fecha_atencion)
HAVING COUNT(a.ate_id) < 10
ORDER BY 1, m.apaterno;