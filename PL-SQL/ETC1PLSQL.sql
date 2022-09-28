--Matías Vigo Muñoz
--Solo me compilan uno a uno y al ejectuar el sp me lanza error.

--PACKAGE
CREATE OR REPLACE PACKAGE PKG_BONIF IS 
 FUNCTION FN_BONIF_ANNIO_TRAB (run_emp number, movilizacion number, fecha_proce date) RETURN NUMBER;
 v_porcent_mov NUMBER;
 v_movilizacion NUMBER;
END;

CREATE OR REPLACE PACKAGE BODY PKG_BONIF IS
 FUNCTION FN_BONIF_ANNIO_TRAB (run_emp number, movilizacion number, fecha_proce date)
 RETURN NUMBER
 IS
   v_porcent number(3,2);
   v_bonif number(8,0);
   v_annios_trab number(2,0);
   v_msn_error varchar2(150);
   v_sueldo number(8,0);
 BEGIN
   BEGIN
      SELECT TRUNC(MONTHS_BETWEEN(fecha_proce,fecing_emp)/12), sueldo_base_emp
      INTO v_annios_trab, v_sueldo
      FROM empleado
      WHERE numrut_emp = run_emp;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_msn_error := SQLERRM;
        v_bonif := 0;
        v_annios_trab := 0;
        INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_BONIF_ANNIO_TRAB ERROR: EMPLEADO NO ENCONTRADO', v_msn_error);
      WHEN OTHERS THEN
        v_msn_error := SQLERRM;
        v_bonif := 0;
        INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_BONIF_ANNIO_TRAB ERROR: OTHERS', v_msn_error);
   END; 
   BEGIN
      SELECT porc_bonif
      INTO v_porcent
      FROM porc_bonif_annos_contrato
      WHERE v_annios_trab BETWEEN annos_inferior AND annos_superior;
   EXCEPTION 
      WHEN NO_DATA_FOUND THEN
        v_msn_error := SQLERRM;
        v_bonif := 0;
        INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_BONIF_ANNIO_TRAB ERROR: PORCENTAJE NO ENCONTRADO CON VALOR DE AÑOS '||v_annios_trab, v_msn_error);
      WHEN OTHERS THEN
        v_msn_error := SQLERRM;
        v_bonif := 0;
        INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_BONIF_ANNIO_TRAB ERROR: OTHERS', v_msn_error);
   END;
   IF v_bonif = 0 THEN 
    RETURN v_bonif;
   ELSE
    v_bonif := ROUND(v_porcent * v_sueldo) + movilizacion;
    RETURN v_bonif;
   END IF;
 END FN_BONIF_ANNIO_TRAB;
END PKG_BONIF;

--FUNCIONES ALMACENADAS
CREATE OR REPLACE FUNCTION FN_CALC_COMISION_VENTAS(run_emp number, fecha_proce date)
RETURN NUMBER
IS
  v_total_comision number(8,0);
  v_msn_error varchar2(200);
BEGIN
    SELECT SUM(c.valor_comision)
    INTO v_total_comision
    FROM empleado e JOIN boleta b ON e.numrut_emp = b.numrut_emp
    JOIN comision_venta c ON b.nro_boleta = c.nro_boleta
    WHERE e.numrut_emp = run_emp AND fecha_proce = b.fecha_boleta
    GROUP BY e.numrut_emp, e.sueldo_base_emp;
    RETURN v_total_comision;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
      v_msn_error := SQLERRM;
      v_total_comision := 0;
      INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_CALC_COMISION ERROR: EMPLEADO RUN '||run_emp||'NO HA EFECTUADO VENTAS ESTE MES', v_msn_error);
      COMMIT;
      RETURN v_total_comision;
    WHEN OTHERS THEN
      v_msn_error := SQLERRM;
      v_total_comision := 0;
      INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_CALC_COMISION ERROR: OTHERS', v_msn_error);
      COMMIT;
      RETURN v_total_comision;
END FN_CALC_COMISION_VENTAS;


CREATE OR REPLACE FUNCTION FN_ASIG_CARGA_FAM(run_emp number, monto_carga number)
RETURN NUMBER
IS
  v_total_carga number(8,0);
  v_cantidad_carga number(2.0);
  v_msn_error varchar2(200);
BEGIN
    SELECT COUNT(c.numrut_emp)
    INTO v_cantidad_carga
    FROM empleado e JOIN carga_familiar c ON e.numrut_emp = c.numrut_emp
    WHERE e.numrut_emp = run_emp
    GROUP BY e.numrut_emp;
    v_total_carga := v_cantidad_carga * monto_carga;
    RETURN v_total_carga;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
      v_msn_error := SQLERRM;
      v_total_carga := 0;
      INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_CARGA_FAM ERROR: EMPLEADO RUN '||run_emp||' NO POSEE CARGAS', v_msn_error);
      COMMIT;
      RETURN v_total_carga;
    WHEN OTHERS THEN
      v_msn_error := SQLERRM;
      v_total_carga := 0;
      INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_CARGA_FAM ERROR: OTHERS', v_msn_error);
      COMMIT;
      RETURN v_total_carga;
END FN_ASIG_CARGA_FAM;


CREATE OR REPLACE FUNCTION FN_BONIF_MOV(run_emp number, fecha_proce date, porcent_mov number, adicional_mov1 number, adicional_mov2 number, monto_carga number)
RETURN NUMBER
IS
  v_total_mov number(8,0);
  v_sueldo_emp number(7,0);
  v_comuna varchar2(30);
  v_categoria varchar2(30);
  v_extra_x_comuna number(8,0);
  v_msn_error varchar2(200);
BEGIN
   SELECT e.sueldo_base_emp, c.nombre_comuna, cat.desc_categoria_emp
   INTO v_sueldo_emp, v_comuna, v_categoria
   FROM empleado e JOIN comuna c ON e.id_comuna = c.id_comuna
   JOIN categoria_empleado cat ON e.id_categoria_emp = cat.id_categoria_emp
   WHERE e.numrut_emp = run_emp;
    
   IF lower(v_categoria) != 'vendedor' AND lower(v_comuna) IN ('la pintana', 'cerro navia','peñalolén') THEN v_extra_x_comuna := adicional_mov1;
   ELSIF lower(v_categoria) != 'vendedor' AND lower(v_comuna) IN ('melipilla', 'maría pinto', 'curacaví', 'talagante', 'isla de maipo','paine') THEN v_extra_x_comuna := adicional_mov2;
   ELSE v_extra_x_comuna := 0;
   END IF;
   v_total_mov := round(v_sueldo_emp*porcent_mov) + v_extra_x_comuna + FN_ASIG_CARGA_FAM(run_emp, monto_carga) + FN_CALC_COMISION_VENTAS(run_emp, fecha_proce);
   RETURN v_total_mov;
EXCEPTION 
  WHEN NO_DATA_FOUND THEN
     v_msn_error := SQLERRM;
     v_total_mov := 0;
     INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_BONIF_MOV ERROR: EMPLEADO RUN '||run_emp||' NO ENCONTRADO', v_msn_error);
     COMMIT;
     RETURN v_total_mov;
  WHEN OTHERS THEN
     v_msn_error := SQLERRM;
     v_total_mov := 0;
     INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'FN_BONIF_MOV ERROR: OTHERS', v_msn_error);
     COMMIT;
     RETURN v_total_mov;
END FN_BONIF_MOV;


--PROCEDIMIENTO PRINCIPAL
CREATE OR REPLACE PROCEDURE SP_CALC_REMUN(porcent_mov number, monto_carga number, valor_colacion number, fecha_proce date, adicional_mov1 number, adicional_mov2 number)
IS
  CURSOR cur_empleado IS
    SELECT DISTINCT(numrut_emp), sueldo_base_emp, TRUNC(MONTHS_BETWEEN(sysdate,fecing_emp)/12) annios_trab
    FROM empleado
    ORDER BY numrut_emp;
  v_msn_error varchar2(200);
BEGIN
  --EXECUTE IMMEDIATE 'TRUNCATE TABLE HABER_CALC_MES';
  --EXECUTE IMMEDIATE 'TRUNCATE TABLE ERROR_PROCESO_REMUN';
  --EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_ERROR';
  --EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_ERROR';
  FOR reg_empleado IN cur_empleado LOOP
    INSERT INTO HABER_CALC_MES
    VALUES (reg_empleado.numrut_emp, EXTRACT(month from fecha_proce), EXTRACT(year from fecha_proce), reg_empleado.annios_trab,
            reg_empleado.sueldo_base_emp, PKG_BONIF.FN_BONIF_ANNIO_TRAB(reg_empleado.numrut_emp, FN_BONIF_MOV(reg_empleado.numrut_emp, fecha_proce, porcent_mov, adicional_mov1, adicional_mov2, monto_carga), fecha_proce),
            FN_ASIG_CARGA_FAM(reg_empleado.numrut_emp, monto_carga), FN_BONIF_MOV(reg_empleado.numrut_emp, fecha_proce, porcent_mov, adicional_mov1, adicional_mov2, monto_carga), valor_colacion, FN_CALC_COMISION_VENTAS(reg_empleado.numrut_emp, fecha_proce),
            reg_empleado.sueldo_base_emp + PKG_BONIF.FN_BONIF_ANNIO_TRAB(reg_empleado.numrut_emp, FN_BONIF_MOV(reg_empleado.numrut_emp, fecha_proce, porcent_mov, adicional_mov1, adicional_mov2, monto_carga), fecha_proce) +
            FN_ASIG_CARGA_FAM(reg_empleado.numrut_emp, monto_carga) + FN_BONIF_MOV(reg_empleado.numrut_emp, fecha_proce, porcent_mov, adicional_mov1, adicional_mov2, monto_carga) + valor_colacion + FN_CALC_COMISION_VENTAS(reg_empleado.numrut_emp, fecha_proce));
    COMMIT;
  END LOOP;
EXCEPTION WHEN OTHERS THEN
  v_msn_error := SQLERRM;
  INSERT INTO error_proceso_remun VALUES (SEQ_ERROR.nextval,'SP_CALC_REMUN ERROR: OTHERS', v_msn_error);
  COMMIT;
END SP_CALC_REMUN;


EXEC SP_CALC_REMUN(0.25, 4500, 40000, '10/07/21', 25000, 40000)

SELECT * FROM haber_calc_mes;

SELECT * FROM error_proceso_remun;
