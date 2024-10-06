create table usuarios(
	identificacion varchar(10) primary key not null,
	nombre varchar(65),
	edad int,
	correo varchar(80)
);

create table facturas(
	id serial primary key,
	fecha date,
	cantidad int,
	valor_unitario numeric,
	valor_total numeric,
	producto varchar(10) not null,
	usuario_id varchar(10),
	foreign key (usuario_id) references usuarios(identificacion)
);

/* PRIMERA PARTE: POBLAR TABLAS */

create or replace function generar_string_random(
	p_longitud integer
)
returns varchar as
$$
DECLARE
    random_string TEXT := '';
    possible_chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    i INT;
BEGIN
    FOR i IN 1..p_longitud LOOP
        random_string := random_string || substr(possible_chars, floor(random() * length(possible_chars))::int + 1, 1);
    END LOOP;
    return random_string;
END $$
language plpgsql


create or replace procedure generar_usuarios()
language plpgsql
as $$
declare
	v_cantidad_clientes integer := 1;
	v_identificacion_r varchar;
	v_nombre_r varchar;
	v_email_r varchar;
	v_edad int;
begin 
	
	while v_cantidad_clientes <= 50 loop

		v_identificacion_r := generar_string_random(10);
		v_nombre_r := generar_string_random(15);
		v_email_r := generar_string_random(15);
		v_edad := floor(1 + random() * 100);

		insert into usuarios(identificacion, nombre, edad ,correo)
		values (v_identificacion_r, v_nombre_r, v_edad, v_email_r);
		v_cantidad_clientes := v_cantidad_clientes + 1;
	end loop;
end;
$$;


create or replace procedure generar_facturas()
language plpgsql
as $$
declare
	v_identificacion varchar;
	v_fecha_r date;
	v_valor_unitario numeric;
	v_valor_total numeric;
	v_cantidad int;
	v_cantidad_facturas integer := 25;
begin 
	
	for v_identificacion in
		select identificacion from usuarios
	loop

		select date '2024-01-01' + (random() * (date '2024-09-01' - date '2024-01-01'))::int
		into v_fecha_r;
		v_cantidad := floor(1 + random() * 100);
		v_valor_unitario := round((1 + random() * 1000)::numeric, 2);
		v_valor_total := v_valor_unitario * v_cantidad;
		
		if v_cantidad_facturas > 0 then
			insert into facturas(fecha, cantidad, valor_unitario, valor_total, producto, usuario_id)
			values (v_fecha_r, v_cantidad, v_valor_unitario, v_valor_total, 'sandia', v_identificacion);
		end if;

		v_cantidad_facturas := v_cantidad_facturas - 1;
	end loop;
end;
$$;

call generar_usuarios();
call generar_facturas();


/* SEGUNDA PARTE: IMPLEMENTACION "PRUEBA_IDENTIFICACION_UNICA" */


create or replace procedure prueba_identificacion_unica()
language plpgsql
as $$
declare
	v_identificacion_valida varchar; 
begin 
	
	insert into usuarios(identificacion, nombre, edad, correo) 
	values('b0fBsjBvZl', 'prueba excepcion', 10, 'prueba@gmail.com');

exception
	when unique_violation then
		rollback;
		v_identificacion_valida := generar_string_random(10);
		insert into usuarios(identificacion, nombre, edad, correo) 
		values(v_identificacion_valida, 'prueba excepcion', 10, 'prueba@gmail.com');
		raise notice 'La identificacion ingresa ya existe en el sistema. Se ha generado una adecuada automaticamente.';
end;
$$;

call prueba_identificacion_unica();


/* TERCERA PARTE: IMPLEMENTACION "PRUEBA_PRODUCTO_VACIO" */


create or replace procedure prueba_producto_vacio()
language plpgsql
as $$
declare
begin 
	
	insert into facturas(fecha, cantidad, valor_unitario, valor_total, producto, usuario_id)
	values ('2024-09-01', 12, 143, 25, 'pera', 'b0fBsjBvZl'),
		   ('2024-09-03', 34, 843, 67, 'b0fBsjBvZl');

exception
	when others then
		rollback;
		raise notice 'Has intentado hacer insertar un null en un atributo not null';
end;
$$;

call prueba_producto_vacio();

/* CUARTA PARTE: IMPLEMENTACION "PRUEBA_CLIENTE_DEBE_EXISTIR" */

create or replace procedure prueba_cliente_debe_existir()
language plpgsql
as $$
declare
begin 
	
	insert into facturas(fecha, cantidad, valor_unitario, valor_total, producto, usuario_id)
	values ('2024-09-01', 12, 143, 25, 'pera', 'b0fBsjBvZl'),
		   ('2024-09-03', 34, 843, 67, 'papaya', 'falsoId');

exception
	when foreign_key_violation then
		rollback;
		raise notice 'Has intentado hacer insertar usando un Id inexistente';
end;
$$;

call prueba_cliente_debe_existir();