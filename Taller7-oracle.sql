ALTER USER INVENTARIO QUOTA UNLIMITED ON USERS;

create table clientes(
identificacion varchar(10) primary key,
nombre varchar(65),
edad integer,
correo varchar(100)
);

create table productos(
    codigo varchar(13) primary key,
    nombre varchar(60) not null,
    stock integer,
    valor_unitario number(10,2) not null
);

create table facturas(
id integer primary KEY NOT NULL,
fecha date not null,
cantidad int,
valor_total number not null,
pedido_estado varchar(20) NOT NUlL check(pedido_estado IN('PENDIENTE', 'BLOQUEADO', 'ENTREGADO')),
producto_id varchar(13) NOT null,
cliente_id varchar(10) NOT null,
foreign key (producto_id) references productos(codigo) on delete cascade,
foreign key (cliente_id) references clientes(identificacion) on delete  cascade
);

INSERT ALL
    INTO productos (codigo, nombre, stock, valor_unitario) VALUES ('1', 'pollo', 17, 25000.00)
    INTO productos (codigo, nombre, stock, valor_unitario) VALUES ('2', 'yuca', 30, 5000.00)
    INTO productos (codigo, nombre, stock, valor_unitario) VALUES ('3', 'arroz', 50, 2500.00)
SELECT * FROM dual;


INSERT ALL
    INTO clientes (identificacion, nombre, edad, correo) VALUES ('1', 'pepe', 40, 'prueba@gmail.com')
    INTO clientes (identificacion, nombre, edad, correo) VALUES ('2', 'pepito', 23, 'pepito@gmail.com')
    INTO clientes (identificacion, nombre, edad, correo) VALUES ('3', 'gildardo', 17, 'papaoso@gmail.com')
SELECT * FROM dual;

      
INSERT ALL
    INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (1, TO_DATE('2024-08-30', 'YYYY-MM-DD'), 1, 240.00, 'ENTREGADO', '1', '1')
    INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (2, TO_DATE('2024-08-27', 'YYYY-MM-DD'), 2, 360.00, 'PENDIENTE', '2', '2')
    INTO facturas (id, fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id) VALUES (3, TO_DATE('2024-08-31', 'YYYY-MM-DD'), 3, 450.00, 'PENDIENTE', '3', '3')
SELECT * FROM dual;


CREATE OR REPLACE PROCEDURE verificar_stock(
	p_producto_id IN varchar,
	p_cantidad_compra IN integer
)
IS
	v_stock_actual integer;
BEGIN 
	select stock into v_stock_actual from productos where codigo = p_producto_id;

	if p_cantidad_compra <= v_stock_actual then
		update productos set stock = v_stock_actual - p_cantidad_compra where codigo = p_producto_id;
		select stock into v_stock_actual from productos where codigo = p_producto_id;
		
		DBMS_OUTPUT.PUT_LINE('Has retirado '|| p_cantidad_compra ||' del stock');
		DBMS_OUTPUT.PUT_LINE('Stock actual: '|| v_stock_actual);
	ELSE
		DBMS_OUTPUT.PUT_LINE('Stock insuficiente');
	end if;
END;

CALL verificar_stock('1', 2);
