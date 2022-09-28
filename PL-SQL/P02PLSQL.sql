--Varables BIND----------------------------------------------
SET SERVEROUTPUT ON;

VAR b_fecha_proce CHAR;
EXEC: b_fecha_proce := to_char(sysdate,'DD/MM/YY');

-------------------------------------------------------------

DECLARE

    TYPE bonif_prem IS VARRAY(2) OF NUMBER(1,2);
    v_bonificaciones bonif_prem;
    
    CURSOR cur_data_socios IS
        SELECT s.nro_socio nro_socio,
               TRUNC(MONTHS_BETWEEN(sysdate,s.fecha_nacimiento)/12) edad,
               INITCAP(TRIM(NVL(s.pnombre, ''))) pnombre,
               INITCAP(TRIM(NVL(s.pnombre, ''))) snombre,
               INITCAP(TRIM(NVL(s.appaterno, ''))) appaterno,
               INITCAP(TRIM(NVL(s.apmaterno, ''))) apmaterno,
               COUNT(s.nro_socio) ctd_producto,
               SUM(ps.monto_total_ahorrado) total_inversion,
               ts.nombre_tipo_socio tipo_socio,
               to_char(s.numrun, '00G999G999') numrun_socio,
               s.dvrun dvrun_socio
        FROM socio s JOIN producto_inversion_socio ps ON(s.nro_socio = ps.nro_socio) JOIN tipo_socio ts ON(s.cod_tipo_socio = ts.cod_tipo_socio)
        GROUP BY s.nro_socio,s.fecha_nacimiento, s.pnombre,s.snombre,s.appaterno,s.apmaterno,ps.monto_total_ahorrado,ts.nombre_tipo_socio,s.numrun,s.dvrun;
    
    CURSOR cur_factor(edad NUMBER) IS
        SELECT factor
        FROM tramo_3ra_edad
        WHERE edad BETWEEN rango_edad_min AND rango_edad_max;
    
    v_nombre_socio    VARCHAR(50);
    v_run_socio       VARCHAR(12);
    v_monto_bono      NUMBER;
    v_monto_total     NUMBER;
    v_nombre_usuario  VARCHAR(20);
    v_clave_usuario   VARCHAR(20);
    v_factor          NUMBER(2,0);
    v_mensj_error     VARCHAR(250);
    v_cod_error       NUMBER(6);
    
BEGIN

    EXECUTE IMMEDIATE('TRUNCATE USUARIO_CLAVE');
    EXECUTE IMMEDIATE('TRUNCATE CLIENTE_PREMIUM');
    EXECUTE IMMEDIATE('TRUNCATE ERROR PROCESO');
    
    FOR reg_socio IN cur_data_socios LOOP
        BEGIN
            --Crear usuario
            IF lower(reg_socio.tipo_socio) LIKE '%dependientes%' THEN 
                v_nombre_usuario := SUBSTR(reg_socio.pnombre, 1, 1)||UPPER(SUBSTR(reg_socio.appaterno, 1, 3))||'$tp.'||reg_socio.nro_socio;
            ELSIF lower(reg_socio.tipo_socio) LIKE '%independientes%' THEN 
                v_nombre_usuario := SUBSTR(reg_socio.pnombre, 1, 1)||UPPER(SUBSTR(reg_socio.appaterno, 1, 3))||'$ti.'||reg_socio.nro_socio;
            ELSE
                v_nombre_usuario := SUBSTR(reg_socio.pnombre, 1, 1)||UPPER(SUBSTR(reg_socio.appaterno, 1, 3))||'$pe.'||reg_socio.nro_socio;
            END IF;
            --Crear contraseña
            BEGIN
                IF cur_factor(reg_socio.edad).factor < 10 THEN
                    v_clave_usuario := SUBSTR(reg_socio.numrun_socio, -1, 3)||'*99'||to_char(cur_factor(reg_socio.edad).factor)||'#00'||reg_socio.dvrun_socio;
                ELSIF cur_factor(reg_socio.edad).factor BETWEEN 10 AND 99 THEN
                    v_clave_usuario := SUBSTR(reg_socio.numrun_socio, -1, 3)||'*9'||to_char(cur_factor(reg_socio.edad).factor)||'#00'||reg_socio.dvrun_socio;
                ELSE
                    v_clave_usuario := SUBSTR(reg_socio.numrun_socio, -1, 3)||to_char(cur_factor(reg_socio.edad).factor)||'#00'||reg_socio.dvrun_socio;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_clave_usuario := SUBSTR(reg_socio.numrun_socio, -1, 3)||'000#00'||reg_socio.dvrun_socio;
                    v_mensj_error := SQLERRM;
                    INSERT INTO error_proceso VALUES (SEQ_ERROR.nextval, 'Error al obtener factor de edad para el socio N°'||to_char(reg_socio.nro_socio), v_mensj_error);
                WHEN TOO_MANY_ROWS THEN
                    v_clave_usuario := SUBSTR(reg_socio.numrun_socio, -1, 3)||'000#00'||reg_socio.dvrun_socio;
                    v_mensj_error := SQLERRM;
                    INSERT INTO error_proceso VALUES (SEQ_ERROR.nextval, 'Error al obtener factor de edad para el socio N°'||to_char(reg_socio.nro_socio), v_mensj_error);
                WHEN OTHERS THEN
                v_clave_usuario := SUBSTR(reg_socio.numrun_socio, -1, 3)||'000#00'||reg_socio.dvrun_socio;
                    v_mensj_error := SQLERRM;
                    INSERT INTO error_proceso VALUES (SEQ_ERROR.nextval, 'Error al obtener factor de edad para el socio N°'||to_char(reg_socio.nro_socio), v_mensj_error);
            END;
            
            v_nombre_socio := reg_socio.pnombre||' '||reg_socio.snombre ||' '||reg_socio.appaterno||' '||reg_socio.apmaterno;
            v_run_socio := reg_socio.numrun_socio||'-'||reg_socio.dvrun_socio;
            INSERT INTO usuario_clave VALUES(reg_socio.nro_socio, v_run_socio, v_nombre_socio, v_nombre_usuario, v_clave_usuario);
            
            --Insertar socio premium
            v_bonificaciones := bonif_prem(.15,.2);
            IF reg_socio.ctd_producto = 2 THEN
                v_monto_bono := ROUND(reg_socio.total_inversion * v_bonificaciones(1));
            ELSE
                v_monto_bono := ROUND(reg_socio.total_inversion * v_bonificaciones(2));
            END IF;
            
            v_monto_total := reg_socio.total_inversion + v_monto_bono;
            
            INSERT INTO cliente_premium VALUES (SEQ_CLIENTE_PREMIUM.nextval, to_char(:b_fecha_proce, 'DD/MM/YY'), reg_socio.nro_socio, reg_socio.edad, v_nombre_socio, reg_socio.ctd_producto, reg_socio.total_inversion, v_monto_bono, v_monto_total);
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN --Por si no encuentro datos en el registro, lo que sucedería con un cursor vacío.
                v_mensj_error := SQLERRM;
                INSERT INTO error_proceso VALUES (SEQ_ERROR.nextval, 'No es posible encontrar socios'||to_char(reg_socio.nro_socio), v_mensj_error);
            WHEN OTHERS THEN
                v_mensj_error := SQLERRM;
                INSERT INTO error_proceso VALUES (SEQ_ERROR.nextval, 'OTRO'||to_char(reg_socio.nro_socio), v_mensj_error);
        END;
    END LOOP;
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;