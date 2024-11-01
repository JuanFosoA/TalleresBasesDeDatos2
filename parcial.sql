
create table pagaya.usuarios(
	identificacion varchar(10) primary key,
	nombre varchar(65),
	direccion varchar(75),
	email varchar(75),
	fecha_registro date,
	estado varchar
);

create table pagaya.tarjetas(
	id serial primary key,
	numero_tarjeta varchar(15),
	fecha_expiracion date,
	cvv varchar(3),
	tipo_tarjeta varchar,
	usuario_id varchar,
	foreign key (usuario_id) references pagaya.usuarios(identificacion)
);

create table pagaya.productos(
	id serial primary key,
	codigo_producto varchar(15),
	nombre varchar(65),
	categoria varchar,
	porcentaje_impuesto numeric,
	precio numeric
);

create table pagaya.pagos(
	id serial primary key,
	codigo_pago varchar(15),
	fecha date,
	estado varchar,
	monto numeric,
	producto_id integer,
	tarjeta_id integer,
	usuario_id varchar(10),
	foreign key (producto_id) references pagaya.productos(id),
	foreign key (tarjeta_id) references pagaya.tarjetas(id),
	foreign key (usuario_id) references pagaya.usuarios(identificacion)
);

create table pagaya.comprobantes_pago(
	id serial primary key,
	detalle_xml xml,
	detalle_json jsonb
);

/* PRIMERA PREGUNTA */

create or replace function pagaya.obtener_pagos_usuario(
	p_usuario_id varchar, p_fecha date
)
returns table(
	codigo_pago varchar,
	nombre_producto varchar,
	monto numeric,
	estado varchar
)
as $$
declare
	v_codigo_pago varchar;
	v_nombre_producto varchar;
	v_monto numeric;
	v_estado varchar;
	v_producto_id integer;
begin
	
	select codigo_pago, estado, monto, producto_id into v_codigo_pago, v_estado, v_monto, v_producto_id from pagaya.pagos
	where usuario_id = p_usuario_id;
	
	select nombre into v_nombre_producto from pagaya.productos where id = v_producto_id;
	
	return 	query;

end;
$$ language plpgsql;



/* SEGUNDA PREGUNTA */


create or replace function pagaya.obtener_tarjetas(
	p_usuario_id varchar
)
returns varchar
as $$
declare
	v_cursor_tarjeta cursor for select * from pagaya.tarjetas where usuario_id = p_usuario_id;
	v_datos varchar;
begin
	open v_cursor_tarjeta;
	fetch v_cursor_tarjeta into v_datos;
	close v_cursor_tarjeta;
	return v_datos;
end;
$$ language plpgsql;


create or replace function pagaya.obtener_pagos_menores_1000(
	p_fecha date
)
returns varchar
as $$
declare
	v_datos varchar;
	v_cursor cursor for select * from pagaya.pagos where fecha = p_fecha and monto <= 1000;
begin 
	open v_cursor;
	fetch v_cursor into v_datos;
	close v_cursor;
	return v_datos;
end;
$$ language plpgsql;


create or replace procedure pagaya.guardar_detalle_xml_json(
	v_detalle_xml xml, v_detalle_json jsonb
)
as $$
begin
	insert into pagaya.comprobantes_pago(detalle_xml, detalle_json)
	values(v_detalle_xml, v_detalle_json);
end;
$$ language plpgsql;


/* TERCER PREGUNTA */

create or replace function pagaya.verificar_precio_producto()
returns trigger 
as $$
begin 
	if new.precio > 0 then
		if new.precio < 20000 then
			insert into pagaya.productos(codigo_producto, nombre, categoria, porcentaje_impuesto, precio )
			values(new.codigo_producto, new.nombre, new.categoria, new.porcentaje_impuesto, new.precio);
		end if;
	end if;
end;
$$ language plpgsql;



create trigger validaciones_producto
before insert 
on pagaya.productos 
for each row
execute function pagaya.verificar_precio_producto();
 

create or replace function pagaya.insertar_pago_con_xml()
returns trigger 
as $$
begin 
	insert into pagaya.pagos(codigo_pago, fecha, estado, monto) 
	values(unnest(xpath('//codigoPago/text()', old.detalle_xml)::text, 
		now(), 
		"Completado",
		unnest(xpath('//montoPago/text()', old.detalle_xml)::text);
end;
$$ language plpgsql;



create trigger trigger_xml
after insert 
on pagaya.comprobantes_pago 
for each row
execute function pagaya.insertar_pago_con_xml();
 
