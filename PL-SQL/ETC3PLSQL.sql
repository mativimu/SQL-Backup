--MATIAS VIGO MUNOZ
--CASO 03
CREATE OR REPLACE PACKAGE PKG_FACTOR_AUMTO_CUPO_COMP IS
FUNCTION F_FACTOR_AUMTO_CUPO_COMP(fecha_inscripcion date) RETURN NUMBER;
PROCEDURE P_GRABAR_ERROR(rutina varchar2 ,msn_error varchar2);
v_numrun_cli number(10,0);
v_dvrun_cli varchar2(1);
v_fecha_proceso date;
v_fecha_nacimiento date;
END PKG_FACTOR_AUMTO_CUPO_COMP;

CREATE OR REPLACE PACKAGE BODY PKG_FACTOR_AUMTO_CUPO_COMP IS
PROCEDURE P_GRABAR_ERROR(rutina varchar2 ,msn_error varchar2) IS
 BEGIN
  EXECUTE IMMEDIATE ('INSERT INTO ERROR_PROCESOS_MENSUALES VALUES ('||to_char(SEQ_ERROR.nextval)||','||rutina||','||msn_error||')');
  COMMIT;
 END P_GRABAR_ERROR;
FUNCTION F_FACTOR_AUMTO_CUPO_COMP(fecha_inscripcion date)
 RETURN NUMBER IS
  v_msn_error varchar2(200);
  v_factor number (4,2);
  v_antiguedad number(2,0);
 BEGIN
  v_antiguedad := trunc(months_between(sysdate, fecha_inscripcion)/12);
  select round((porc_aumento/100), 2)
  into v_factor
  from rango_aumento_cupocompra
  where v_antiguedad between ant_min and ant_max;
  return v_factor;
 EXCEPTION WHEN OTHERS THEN
  v_factor := 0;
  v_msn_error := SQLERRM;
  P_GRABAR_ERROR('F_FACTOR_AUMTO_CUPO_COMP' ,v_msn_error);
  return v_factor;
 END F_FACTOR_AUMTO_CUPO_COMP;
END PKG_FACTOR_AUMTO_CUPO_COMP;

CREATE OR REPLACE FUNCTION FN_FACTOR_AUMTO_CUPO_AVANCE(fecha_nacimiento date)
RETURN NUMBER
IS
 v_msn_error varchar2(200);
 v_factor number(4,2);
 v_edad number(2,0);
BEGIN
 v_edad := trunc(months_between(sysdate, fecha_nacimiento)/12);
 select round((porc_aumento/100), 2)
 into v_factor
 from rango_aumento_superavance
 where v_edad between edad_min and edad_max;
 return v_factor;
EXCEPTION WHEN OTHERS THEN
 v_factor := 0;
 v_msn_error := SQLERRM;
 PKG_FACTOR_AUMTO_CUPO_COMP.P_GRABAR_ERROR('FN_FACTOR_AUMTO_CUPO_AVANCE' ,v_msn_error);
 return v_factor;
END FN_FACTOR_AUMTO_CUPO_AVANCE;

CREATE OR REPLACE PROCEDURE PS_AUMENTOS_MES_CLIENTE
AS
 cursor cur_clientes_select is
    select * 
    from cliente cl join ocupacion oc
    on cl.cod_ocupacion = oc.cod_ocupacion
    join tarjeta_cliente tcl
    on cl.numrun = tcl.numrun
    where lower(oc.nombre_prof_ofic) like '%técnico%' or lower(oc.nombre_prof_ofic) like '%ingeniero%'
    and extract(month from fecha_nacimiento) = extract(month from add_months(sysdate,-1));
 v_cupo_compra number(10,0);
 v_cupo_avance number(10,0);
 v_msn_error varchar2(200);
BEGIN
 EXECUTE IMMEDIATE ('TRUNCATE AUMENTOS_MES_CLIENTE');
 EXECUTE IMMEDIATE ('TRUNCATE ERROR_PROCESOS_MENSUALES');
 EXECUTE IMMEDIATE ('DROP SEQUENCE SEQ_ERROR');
 EXECUTE IMMEDIATE ('CREATE SEQUENCE SEQ_ERROR');
 FOR reg_cur_clientes_select IN cur_clientes_select LOOP
   pkg_factor_aumto_cupo_comp.v_dvrun_cli := reg_cur_clientes_select.dvrun;
   pkg_factor_aumto_cupo_comp.v_numrun_cli := reg_cur_clientes_select.numrun;
   pkg_factor_aumto_cupo_comp.v_fecha_nacimiento := reg_cur_clientes_select.fecha_nacimiento;
   pkg_factor_aumto_cupo_comp.v_fecha_proceso := sysdate;
   v_cupo_compra := pkg_factor_aumto_cupo_comp.f_factor_aumto_cupo_comp(reg_cur_clientes_select.fecha_inscripcion)*reg_cur_clientes_select.cupo_compra;
   v_cupo_avance := fn_factor_aumto_cupo_avance(reg_cur_clientes_select.fecha_nacimiento)*reg_cur_clientes_select.cupo_super_avance;
   INSERT INTO aumentos_mes_cliente
   VALUES(pkg_factor_aumto_cupo_comp.v_fecha_proceso, pkg_factor_aumto_cupo_comp.v_numrun_cli,
          pkg_factor_aumto_cupo_comp.v_dvrun_cli, pkg_factor_aumto_cupo_comp.v_fecha_nacimiento,
          v_cupo_compra, v_cupo_avance);
   COMMIT;
 END LOOP;
EXCEPTION WHEN OTHERS THEN
 v_msn_error := SQLERRM;
 PKG_FACTOR_AUMTO_CUPO_COMP.P_GRABAR_ERROR('PS_AUMENTOS_MES_CLIENTE' ,v_msn_error);
END PS_AUMENTOS_MES_CLIENTE;