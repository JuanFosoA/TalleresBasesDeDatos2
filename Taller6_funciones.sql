create type estado as enum ('pago', 'no_pago', 'pendiente_pago');

create type tipo_servicio as enum ('agua', 'luz', 'gas');

create table clientes(
	identificacion varchar(10) primary key,
	nombre varchar(65),
	email varchar(100),
	direccion varchar(60),
	telefono varchar(10)
);

create table servicios(
	codigo varchar(10) primary key,
	tipo TIPO_SERVICIO,
	monto numeric,
	cuota integer,
	intereses numeric,
	valor_total numeric,
	estado Estado,
	cliente_id varchar(10),
	foreign key (cliente_id) references clientes(identificacion) on delete cascade
);

create table pagos(
	codigo varchar(10) primary key,
	fecha_pago date,
	total numeric,
	servicio_id varchar(10),
	foreign key (servicio_id) references servicios(codigo) on delete cascade
);

/* Crear cadena de x longitud aleatoria */
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

/*TALLER 6 PARTE 1*/
create or replace procedure generar_clientes()
language plpgsql
as $$
declare
	v_cantidad_clientes integer := 1;
	v_identificacion_r varchar;
	v_nombre_r varchar;
	v_email_r varchar;
	v_direccion_r varchar;
	v_telefono_r varchar;
begin 
	
	while v_cantidad_clientes <= 50 loop

		v_identificacion_r := generar_string_random(10);
		v_nombre_r := generar_string_random(15);
		v_email_r := generar_string_random(15);
		v_direccion_r := generar_string_random(8);
		v_telefono_r := generar_string_random(10);

		insert into clientes(identificacion, nombre, email, direccion, telefono)
		values (v_identificacion_r, v_nombre_r, v_email_r, v_direccion_r, v_telefono_r);
		v_cantidad_clientes := v_cantidad_clientes + 1;
	end loop;
end;
$$;

create or replace procedure generar_servicios()
language plpgsql
as $$
declare
	v_cantidad_servicios integer := 1;
	v_identificacion varchar;
	v_codigo_r varchar;
	v_estado Estado;
	v_tipo TIPO_SERVICIO;
	v_interes numeric;
begin 
	
	while v_cantidad_servicios <= 3 loop

		for v_identificacion in
			select identificacion from clientes
		loop

			if v_cantidad_servicios = 1 then
				v_estado := 'pago';
				v_tipo := 'agua';
			elsif v_cantidad_servicios = 2 then
				v_estado := 'no_pago';
				v_tipo := 'luz';		
			else
				v_estado := 'pendiente_pago';
				v_tipo := 'gas';		
			end if;
						
			v_codigo_r := generar_string_random(10);
			v_interes := (v_cantidad_servicios * 100) * 0.1;			

			insert into servicios(codigo, tipo, monto, cuota, intereses, valor_total, estado, cliente_id)
			values (v_codigo_r, v_tipo , v_cantidad_servicios * 100, v_cantidad_servicios * 3, v_interes ,3000, v_estado, v_identificacion);
		end loop;

		
		v_cantidad_servicios := v_cantidad_servicios + 1;
	end loop;
end;
$$;


create or replace procedure generar_pagos()
language plpgsql
as $$
declare
	v_codigo_servicio varchar;
	v_identificacion varchar;
	v_codigo_pago varchar;
	v_fecha_r date;
	v_total_r float;
	v_bandera integer;
begin 
	
	for v_identificacion in
		select identificacion from clientes
	loop

		v_bandera := 0;
		v_codigo_pago := generar_string_random(10);
		select date '2024-01-01' + (random() * (date '2024-09-01' - date '2024-01-01'))::int
		into v_fecha_r;
		v_total_r := round((1 + random() * 1000)::numeric, 2);

		for v_codigo_servicio in
			select codigo from servicios where cliente_id = v_identificacion
		loop

			if v_bandera != 0 then
				continue;
			end if;

			insert into pagos(codigo, fecha_pago, total, servicio_id)
			values (v_codigo_pago, v_fecha_r, v_total_r, v_codigo_servicio);
			v_bandera := 1;

		end loop;
	end loop;
end;
$$;

call generar_clientes();
call generar_servicios();
call generar_pagos();


/*TALLER 6 PARTE 2*/

create or replace function transacciones_total_mes(
	p_identificacion varchar,
	p_mes integer
)
returns numeric as 
$$
declare
	v_pago numeric;
	v_total_pago numeric := 0;
begin 
	
	for v_pago in
		select total from pagos p
		join servicios s on p.servicio_id = s.codigo
		join clientes c on s.cliente_id = c.identificacion
		where extract(month from fecha_pago) = p_mes
		and c.identificacion = p_identificacion
	loop
		v_total_pago := v_total_pago + v_pago;
	end loop; 
	return v_total_pago;
end $$
language plpgsql

select transacciones_total_mes('P9z6Dnhiea', 8);
