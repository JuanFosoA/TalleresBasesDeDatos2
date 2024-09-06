create table auditorias(
	id serial primary key,
	fecha_inicio date not null,
	fecha_final date not null,
	factura_id int,
	pedido_estado PEDIDO_ESTADO not null,
	foreign key (factura_id) references facturas(id) on delete cascade
);

/* Actividad de clase*/
create or replace procedure calcular_stock_total()
language plpgsql
as $$
declare
	v_total_stock integer :=0;
	v_stock_actual integer;
	v_nombre_producto varchar;
begin
	
	for v_nombre_producto, v_stock_actual in 
		select nombre, stock from productos
	loop
		raise notice 'El nombre del producto es: %', v_nombre_producto;
		raise notice 'El stock actual del producto es de: %', v_stock_actual;
		v_total_stock := v_total_stock + v_stock_actual;
	end loop;	
	raise notice 'El stock total es de: %', v_total_stock;
end;
$$;

/* Ejercicio 1 */
create or replace procedure generar_auditoria(
	p_fecha_inicio date,
	p_fecha_fin date
)
language plpgsql
as $$
declare 
	v_factura_id int;
	v_factura_fecha date;
	v_pedido_estado PEDIDO_ESTADO;
begin
	for v_factura_id, v_factura_fecha, v_pedido_estado in
		select id, fecha, pedido_estado from facturas
	loop
		if v_factura_fecha between p_fecha_inicio and p_fecha_fin then
			insert into auditorias (fecha_inicio, fecha_final, factura_id, pedido_estado)
			values (p_fecha_inicio, p_fecha_fin, v_factura_id, v_pedido_estado);
		end if;
	end loop;
end;
$$;

/* Ejercicio 2 */
create or replace procedure simular_ventas_mes()
language plpgsql
as $$
declare
	v_dia integer := 1;
	v_identificacion varchar;
	random_cantidad integer;
	random_valor numeric;
begin
	while v_dia <= 30 loop
		for v_identificacion in
			select identificacion from clientes
		loop
			random_cantidad := floor(1 + random() * 100);
			random_valor := round((1 + random() * 99)::numeric, 2);
			insert into facturas(fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id)
			values ('2024-08-02', random_cantidad, random_valor, 'PENDIENTE', '2', v_identificacion );
		end loop;
		v_dia := v_dia + 1;
	end loop;	
end;
$$;



select * from facturas;
select * from auditorias;

call simular_ventas_mes();
call generar_auditoria('2024-08-28','2024-09-1');
call calcular_stock_total();