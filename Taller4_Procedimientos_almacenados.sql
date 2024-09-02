create table clientes(
identificacion varchar(10) primary key,
nombre varchar(65),
edad int,
correo varchar(100)
);

create table productos(
    codigo varchar(13) primary key,
    nombre varchar(60) not null,
    stock integer,
    valor_unitario decimal(10, 2) not null
);

create type pedido_estado as enum ('PENDIENTE', 'BLOQUEADO', 'ENTREGADO');

create table facturas(
id serial primary key,
fecha date not null,
cantidad int,
valor_total numeric not null,
pedido_estado PEDIDO_ESTADO not null,
producto_id varchar(13) not null,
cliente_id varchar(10) not null,
foreign key (producto_id) references productos(codigo) on delete cascade,
foreign key (cliente_id) references clientes(identificacion) on delete  cascade
);

insert into productos (codigo, nombre, stock, valor_unitario) 
values ('1','pollo', 17, 25000.00),
       ('2','yuca', 30, 5000.00),
       ('3','arroz', 50, 2500.00);

  
insert into clientes (identificacion, nombre, edad, correo) 
values ('1','pepe', 40, 'prueba@gmail.com'),
       ('2','pepito', 23, 'pepito@gmail.com'),
       ('3','gildardo', 17, 'papaoso@gmail.com');

      
/* Ejercicio 1*/
create or replace procedure verificar_stock(
	p_producto_id varchar,
	p_cantidad_compra integer
)
language plpgsql
as $$
declare 
	v_stock_actual int;
begin

	select stock into v_stock_actual from productos where codigo = p_producto_id;

	if p_cantidad_compra <= v_stock_actual then
		update productos set stock = v_stock_actual - p_cantidad_compra where codigo = p_producto_id;
		select stock into v_stock_actual from productos where codigo = p_producto_id;

		Raise notice 'Has retirado: % del stock', p_cantidad_compra;
		Raise notice 'Stock actual: %', v_stock_actual;
	else
		Raise notice 'Stock insuficiente';
	end if;

end;
$$;

/* Ejercicio 2*/
create or replace procedure actualizar_estado_pedido(
	p_factura_id integer,
	p_nuevo_estado PEDIDO_ESTADO
)
language plpgsql
as $$
declare 
	v_estado_actual PEDIDO_ESTADO;
begin
	
	select pedido_estado into v_estado_actual from facturas where id = p_factura_id;
	
	if v_estado_actual = 'ENTREGADO' then
		raise notice 'EL PEDIDO YA FUE ENTREGADO';
	else
		update facturas set pedido_estado = p_nuevo_estado where id = p_factura_id;
		raise notice 'EL ESTADO FUE ACTUALIZADO';
	end if;
end;
$$;

insert into facturas (fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) 
values ('2024-08-30',1 , 240.00, 'ENTREGADO', '1', '1'),
       ('2024-08-27', 2, 360.00, 'PENDIENTE', '2', '2'),
       ('2024-08-31', 3, 450.00, 'PENDIENTE', '3', '3');


select pedido_estado from facturas where id = 2;
      
select * from productos;

call verificar_stock('1', 16);
call actualizar_estado_pedido(2, 'BLOQUEADO');
