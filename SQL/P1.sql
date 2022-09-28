PRUEBA 1 -- MATÍAS VIGO MUÑOZ

-----CASO1

-Mencione una optimización a su solución que se podría implementar (no es necesario poner el código, pero debe explicarlo):

En terminos generales, a partir de la tabla cliente se construye el listado con sus respectivos correos y fechas. Primero formateamos los 
nombres, usando las funciones LOWER(), INITCAP(), SUBSTR() y INSTR() para corregir espacios y poner en minúscula y mayúscula donde corresponda.
Luego usamos CASE para asignar las fechas según las iniciales del nombre, las cuales las obtenemos usando nuevamente SUBSTR(). Finalizando, para
generar el correo utilizamos la función SUBSTR() para extraer los carácteres que necesitamos y el comando "||" para concatenar y dar forma.

-Cuál es la información significativa que necesita para resolver el problema y por qué, cree usted, que es necesario realizar el listado que le solicitaron.

La información significativa para resolver el problema está en la descripción del requisito, es decir, qué y cómo quieren la información. En este caso se pide
un listado de los clientes, con nombre, fecha de citación (según el conjunto de letras al que pertenezca la primera letra del nombre) y correo respectivo
(generado conforme a las reglas que nos presentan).

-Qué tipo de Case utilizó? ¿Podría haber usado el otro CASE?

Usé el formato

CASE 
    WHEN (condición)... THEN ...

Porque la expresión en la condición puede asumir cualquier valor dentro de un conjunto o intervalo. Con lo cual, no es posible usar el formato

CASE (expresión)
   WHEN (condición)... THEN...

puesto que se necesita de un valor fijo para la expresión dentro de la condición.


-CÓDIGO

SELECT 
       INITCAP(LOWER(SUBSTR(nombre, 1, INSTR(nombre, ' ', 1, 1) -1))) || ' ' ||
       INITCAP(LOWER(LTRIM(SUBSTR(nombre, INSTR(nombre, ' ', 1, 1), LENGTH(nombre))))) AS "LISTADO DE CLIENTES",
       CASE
            WHEN UPPER(SUBSTR(nombre, 1, 1)) IN ('A','B','C','D','E','F','G','H','I','J') THEN '30 SEPTIEMBRE DEL 2020'
            WHEN UPPER(SUBSTR(nombre, 1, 1)) IN ('K','L','M','N') THEN '30 OCTUBRE DEL 2020   '
            WHEN UPPER(SUBSTR(nombre, 1, 1)) IN ('O','P','Q','R','S') THEN '30 NOVIEMBRE DEL 2020 '
       ELSE '30 DICIEMBRE DEL 2020 '
       END AS "Citar el: ",
       INITCAP(SUBSTR(nombre, 1, 3))||'.'||SUBSTR(telefono, -4)||'@gmail.com' AS "E-mail generado"
       
FROM cliente
ORDER BY 2 desc, 1 desc;



-----CASO2

-CÓDIGO

CREATE TABLE RESPALDO_CLIENTE AS
SELECT '000'||SUBSTR(rutcliente, 1, INSTR(rutcliente,'-',  1, 1)-1) AS "RUN",
       SUBSTR(rutcliente, -1) AS "DV",
       INITCAP(LOWER(SUBSTR(nombre, 1, INSTR(nombre, ' ', 1, 1) -1))) AS "PRIMER NOMBRE",
       INITCAP(LOWER(TRIM(SUBSTR(nombre, INSTR(nombre, ' ', 1, 1), LENGTH(nombre))))) AS "APELLIDO", 
       to_char(credito, '$9G999G999') AS "CREDITO",
       estado AS "ESTADO",
       to_char(fecha_carga, 'MONTH') AS "MES CARGA"

FROM cliente
WHERE EXTRACT( month from fecha_carga ) = EXTRACT( month from ADD_MONTHS(sysdate, -1)) 
--and credito between 800000 and 1800000 --(agregar esta condición para que la query quede exacto al ejemplo)
ORDER BY rutcliente;


-Explique la estrategia que utilizó para cortar y separar los nombres de los apellidos y para crear la tabla a partir de su query. 
¿Con qué problema específico se encontró en el desarrollo?

Para atomizar los datos nombre y apellido hice el siguiente razonamiento: Puesto que el espacio (' ') es lo que separa el nombre del apellido lo tomo como 
punto de partida o referencia, y utilizo la función INSTR(nombre, ' ', 1, 1) para conocer su ubicación. Luego, con ello, "extraigo" el nombre con 
SUBSTR(nombre, 1, INSTR(nombre, ' ', 1, 1)-1), restándole uno a la posición del espacio, ya que no lo necesito. Finalmente formateo con LOWER() e INITCAP(). 
Para el apellido, sigo la misma lógica pero con algunos cambios. la "extracción" del apellido es con SUBSTR(), pero ahora con punto de partida la ubicación del
espacio, desde ahí extraigo hasta el final del char, el cual lo indico con su largo LENGTH, resultando la sentencia SUBSTR(nombre, INSTR(nombre, ' ', 1, 1), LENGTH(nombre)).
Seguido de ello aplico TRIM() para "limpiar" de espacios y formateo con LOWER() e INITCAP().

En cuanto a algún problema específico, cuando inserté el código CREATE TABLE RESPALDO_CLIENTE AS me dejó de reconocer el atributo rutcliente, pero al cortar y pegar
varias veces el código (con el drop table entre medio) me lo reconoció, al parecer fue un error "de procesamiento" el programa, no estoy muy seguro.



-----CASO3

SELECT CASE codpais
            WHEN 1 THEN 'Chile'
            WHEN 2 THEN 'Estados Unidos'
            WHEN 7 THEN 'Agentina'
       ELSE 'No aplica'
       END AS "PAIS",
       UPPER(descripcion) AS "PRODUCTO",
       to_char(vunitario, '99G999G999') AS "UNITARIO",
       to_char((NVL(valorcompradolar, 0) * &valor_dolar), '$999G999G999') AS "VALOR CONVERSION"
       
FROM producto
WHERE (UPPER(descripcion) LIKE '%FRENA%' or UPPER(descripcion)LIKE '%ACEITE%') and codpais IN (1, 2, 7)
ORDER BY 1, 4 desc;



-----CASO4

-CÓDIGO

SELECT  rutvendedor AS "RUT VENDEDOR",
        INITCAP(LOWER(REPLACE(nombre, '  ', ' '))) AS "NOMBRE VENDEDOR",
        sueldo_base AS "BASE",
        to_char(comision, '0D0') AS "COMISION",
        CASE 
        WHEN round((( to_number(SUBSTR(hora_termino, 1, 2))* 60 + to_number(SUBSTR(hora_termino, -2))) - (to_number(SUBSTR(hora_inicio, 1, 2))* 60 + to_number(SUBSTR(hora_inicio, -2))))/60)*24 -(45*4) < 0 THEN 0
        ELSE ( round((( to_number(SUBSTR(hora_termino, 1, 2))* 60 + to_number(SUBSTR(hora_termino, -2))) - (to_number(SUBSTR(hora_inicio, 1, 2))* 60 + to_number(SUBSTR(hora_inicio, -2))))/60)*24 -(45*4) )/4
        END AS "HORAS EXTRAS",
        CASE 
        WHEN round((( to_number(SUBSTR(hora_termino, 1, 2))* 60 + to_number(SUBSTR(hora_termino, -2))) - (to_number(SUBSTR(hora_inicio, 1, 2))* 60 + to_number(SUBSTR(hora_inicio, -2))))/60)*24 -(45*4) < 0 THEN 0
        ELSE (( round((( to_number(SUBSTR(hora_termino, 1, 2))* 60 + to_number(SUBSTR(hora_termino, -2))) - (to_number(SUBSTR(hora_inicio, 1, 2))* 60 + to_number(SUBSTR(hora_inicio, -2))))/60)*24 -(45*4) )/4 ) *5700
        END AS "VALOR HH EXTRAS SEMANAL"
        
FROM vendedor;