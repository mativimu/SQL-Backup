--MATÍAS VIGO MUÑOZ
-----------------------------------------------------------------


TRUNCATE TABLE CALC_HABERES_X_MES;

--VARIABLES BIND

VAR b_valor_carga   NUMBER;
VAR b_mes_proce     NUMBER;
VAR b_anno_proce    NUMBER;

EXEC :b_valor_carga     := 6500;
EXEC :b_mes_proce       := EXTRACT(MONTH FROM SYSDATE);
EXEC :b_anno_proce      := EXTRACT(YEAR FROM SYSDATE);

--BLOQUE

DECLARE

    ----------------------------------------------
    --Datos para iterar clientes
    v_min_id        NUMBER(10,0);
    v_max_id        NUMBER(10,0);
    ----------------------------------------------
    --Datos base del empleado
    v_numrut        NUMBER(10,0);
    v_sueldo        NUMBER(8,0);
    v_categoria     NUMBER(1.0);
    v_annos_trab    NUMBER(2,0);
    ----------------------------------------------
    --Asignacion Especial Años Contratados
    v_porc_bonif    NUMBER(3,0);
    v_valor_asign   NUMBER(8,0);
    ----------------------------------------------
    --Asignacion Carga Familiar
    v_carga         NUMBER(2,0);
    v_total_carga   NUMBER(8,0);
    ----------------------------------------------
    --Movilización y Colación
    v_valor_mov     NUMBER(8,0);
    v_valor_col     NUMBER (8,0);
    ----------------------------------------------
    --Comisión
    v_com_ventas    NUMBER(8,0);
    ----------------------------------------------
    --Total
    v_total_haberes NUMBER(10,0);


BEGIN

    ------------------------------------------------------------------
     --Extraer ID mínimo y máximo
    BEGIN
        SELECT MIN(id_empleado),MAX(id_empleado) 
        INTO v_min_id, v_max_id
        FROM empleado;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('PROBLEMS FINDING MIN ID AND MAX ID');
    END;
    ------------------------------------------------------------------
    
    
    FOR i IN v_min_id .. v_max_id LOOP
    
       ---------------------------------------------------------------------------------------------------------
        --Extraer datos base del empleado
        BEGIN
            SELECT numrut_emp, sueldo_base_emp, id_categoria_emp, TRUNC(MONTHS_BETWEEN(SYSDATE,FECING_EMP)/12)
            INTO v_numrut, v_sueldo, v_categoria, v_annos_trab
            FROM empleado WHERE id_empleado = i;
        EXCEPTION WHEN NO_DATA_FOUND THEN
           DBMS_OUTPUT.PUT_LINE('NOT EMPLOYEE DATA FOUND'); 
        END;
       ----------------------------------------------------------------------------------------------------------
        
       ----------------------------------------------------------------------------------------------------------
        --Calcular Asignación por años Trabajados
        BEGIN
            SELECT porc_bonif 
            INTO v_porc_bonif
            FROM bonificacion_x_anhos WHERE v_annos_trab BETWEEN annos_inferior AND annos_superior;
            v_valor_asign := ROUND(v_sueldo*(v_porc_bonif/100));
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_valor_asign := 0;
        END;
       ---------------------------------------------------------------------------------------------------------
       
       ---------------------------------------------------------------------------------------------------------
        --Monto por Carga Familiar
        BEGIN
            SELECT COUNT(numrut_emp)
            INTO v_carga
            FROM carga_familiar WHERE numrut_emp = v_numrut;
            v_total_carga := v_carga * :b_valor_carga;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_total_carga := 0;
        END;
       ---------------------------------------------------------------------------------------------------------
       
       ---------------------------------------------------------------------------------------------------------
        --Monto Movilización
        BEGIN
            IF v_categoria = 1 THEN
                v_valor_mov := ROUND(v_sueldo * 0.3);
            ELSIF v_categoria = 2 THEN
                v_valor_mov := ROUND(v_sueldo * 0.4);
            ELSIF v_categoria = 3 THEN
                v_valor_mov := ROUND(v_sueldo * 0.1);
            ELSE
                v_valor_mov := ROUND(v_sueldo * 0.05);
            END IF;
        END;
       ---------------------------------------------------------------------------------------------------------
       
       ---------------------------------------------------------------------------------------------------------
        --Monto Colación
        BEGIN
            IF v_categoria = 1 THEN
                v_valor_col := ROUND(v_sueldo * 0.2);
            ELSIF v_categoria = 2 THEN
                v_valor_col := ROUND(v_sueldo * 0.3);
            ELSIF v_categoria = 3 THEN
                v_valor_col := ROUND(v_sueldo * 0.1);
            ELSE
                v_valor_col := ROUND(v_sueldo * 0.1);
            END IF;
        END;
       ---------------------------------------------------------------------------------------------------------
       v_com_ventas := 0;
       ---------------------------------------------------------------------------------------------------------
        --Comisión
        BEGIN
            SELECT SUM(cv.valor_comision)
            INTO v_com_ventas
            FROM boleta b JOIN comision_venta cv ON(b.nro_boleta = cv.nro_boleta) WHERE v_numrut = b.numrut_emp GROUP BY b.numrut_emp;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_com_ventas := 0;
        END;
       --------------------------------------------------------------------------------------------------------
       
       --------------------------------------------------------------------------------------------------------
        --Total Haberes
        v_total_haberes := v_sueldo + v_valor_asign + v_total_carga + v_valor_mov + v_valor_col + v_com_ventas;
        
       --------------------------------------------------------------------------------------------------------
        --Insertar datos en CALC_HABERES_X_MES
        
        INSERT INTO CALC_HABERES_X_MES(numrut_emp, mes_proceso, anno_proceso, valor_sueldo_base, valor_asig_annos, valor_cargas_fam, valor_movilizacion, valor_colacion, valor_com_ventas, valor_tot_haberes)
        VALUES (v_numrut, :b_mes_proce, :b_anno_proce, v_sueldo, v_valor_asign, v_total_carga, v_valor_mov, v_valor_col, v_com_ventas, v_total_haberes);
        
        
    END LOOP;
    
    COMMIT;
EXCEPTION WHEN OTHERS THEN
    
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
        
END;