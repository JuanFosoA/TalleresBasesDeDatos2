create table actividadtrigger.empleados(
	identificacion varchar primary key,
	nombre varchar,
	edad int,
	correo varchar,
	salario numeric
);

 create table actividadtrigger.nominas(
 	id serial primary key,
 	fecha date,
 	total_ingresos numeric,
 	total_deducciones numeric,
 	total_neto numeric,
 	empleado_id varchar,
 	foreign key (empleado_id) references empleados(identificacion)
 );
 
create table actividadtrigger.detalle_nominas(
	id serial primary key,
	concepto varchar,
	tipo varchar,
	valor numeric,
	nomina_id integer,
	foreign key (nomina_id) references nominas(id)
);

create table actividadtrigger.auditoria_nomina(
 	id serial primary key,
 	fecha date,
 	total_neto numeric,
 	nombre varchar,
 	identificacion varchar
 );

create table actividadtrigger.auditoria_empleado(
 	id serial primary key,
 	fecha date,
 	valor numeric,
 	nombre varchar,
 	identificacion varchar,
 	concepto varchar
 );

/* PUNTO UNO */
create or replace function actividadtrigger.verificar_presupuesto_nomina()
returns trigger as
$$
declare
	v_presupuesto_usado numeric := 0;
	v_salario numeric;
	v_total_neto numeric;
begin
	/* Suma total neto de nominas */
	for v_total_neto in 
		select total_neto from actividadtrigger.nominas where extract(month from fecha) = extract(month from new.fecha)
	loop
		v_presupuesto_usado := v_presupuesto_usado + v_total_neto;
	end loop;
	
	v_presupuesto_usado := v_presupuesto_usado + new.total_neto;	

	if	v_presupuesto_usado > 12000000 then
		raise exception 'PRESUPUESTO MENSUAL SUPERADO';
	end if;
	return new;
end;
$$
language plpgsql;

create trigger tg_verificar_presupuesto_nomina
before insert on actividadtrigger.nominas 
for each row execute procedure actividadtrigger.verificar_presupuesto_nomina()


insert into actividadtrigger.empleados(identificacion, nombre, edad, correo, salario)
values('123', 'juan', 21, 'j@j', 120000),
	('345', 'fran', 22, 'k@j', 120500),
    ('567', 'cisco', 26, 'f@f', 160000);
    
/* Probando  */
insert into actividadtrigger.nominas(fecha, total_ingresos, total_deducciones, 	total_neto, empleado_id)
values('2024-10-05', 11000000, 1, 11000000, '123');


/* PUNTO DOS */


create or replace function actividadtrigger.generar_auditoria_nomina()
returns trigger as
$$
declare
	v_nombre_empleado varchar;
begin
	
	select e.nombre into v_nombre_empleado
	from actividadtrigger.empleados e
	where e.identificacion = new.empleado_id;
	
	insert into actividadtrigger.auditoria_nomina(fecha, total_neto, nombre, identificacion)
	values (new.fecha, new.total_neto , v_nombre_empleado , new.empleado_id);
	return new;
end;
$$
language plpgsql;

create trigger tg_generar_auditoria_nomina
after insert on actividadtrigger.nominas 
for each row execute procedure actividadtrigger.generar_auditoria_nomina();


/* Probando  */
insert into actividadtrigger.nominas(fecha, total_ingresos, total_deducciones, 	total_neto, empleado_id)
values('2024-10-05', 1000, 10, 990, '567');


/* PUNTO TRES */

create or replace function actividadtrigger.verificar_presupuesto_salario()
returns trigger as
$$
declare
	v_presupuesto_usado numeric := 0;
	v_salario numeric;
begin
	/* Suma total neto de salarios */
	for v_salario in 
		select salario from actividadtrigger.empleados where identificacion != old.identificacion
	loop
		v_presupuesto_usado := v_presupuesto_usado + v_salario;
	end loop;
	
	v_presupuesto_usado := v_presupuesto_usado + new.salario;	

	if	v_presupuesto_usado > 12000000 then
		raise exception 'PRESUPUESTO MENSUAL SUPERADO';
	end if;
	return new;
end;
$$
language plpgsql;


create trigger tg_verificar_presupuesto_salario
before update on actividadtrigger.empleados 
for each row execute procedure actividadtrigger.verificar_presupuesto_salario()

update empleados set salario = 180000 where identificacion = '123';
update empleados set salario = 670000 where identificacion = '567';


/* PUNTO CUATRO */

create or replace function actividadtrigger.generar_auditoria_empleado()
returns trigger as
$$
declare
	v_concepto varchar;
	v_valor numeric;
begin
	
	if old.salario < new.salario  then
		v_concepto := 'AUMENTO';
		v_valor := new.salario - old.salario;
	else
		v_concepto := 'DISMINUCION';
		v_valor := old.salario - new.salario;
	end if;
	
	insert into actividadtrigger.auditoria_empleado(fecha, valor, nombre, identificacion, concepto)
	values (now(), v_valor , old.nombre , old.identificacion, v_concepto);
	return new;
end;
$$
language plpgsql;

create trigger tg_generar_auditoria_empleado
after update on actividadtrigger.empleados 
for each row execute procedure actividadtrigger.generar_auditoria_empleado();


/* PROBANDO */

update empleados set salario = 170000 where identificacion = '123';
update empleados set salario = 680000 where identificacion = '567';
