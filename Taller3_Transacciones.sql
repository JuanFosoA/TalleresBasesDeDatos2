create table clientes(
    identificacion varchar(10) primary key,
    nombre varchar(60) not null,
    edad int,
    correo varchar(65) not null
);

create table productos(
    codigo varchar(13) primary key,
    nombre varchar(60) not null,
    stock int,
    valor_unitario decimal(10, 2) not null
);

create table pedidos(
    id serial primary key,
    fecha date not null,
    cantidad int not null,
    valor_total decimal(10, 2) not null,
    producto_id varchar(13) not null,
    cliente_id varchar(10) not null,
    foreign key (producto_id) references productos(codigo) on delete cascade,
    foreign key (cliente_id) references clientes(identificacion) on delete  cascade
);


begin;

insert into clientes (identificacion, nombre, edad, correo) 
values ('1','pepe', 40, 'prueba@gmail.com'),
       ('2','pepito', 23, 'pepito@gmail.com'),
       ('3','gildardo', 17, 'papaoso@gmail.com');

insert into productos (codigo, nombre, stock, valor_unitario) 
values ('1','pollo', 17, 25000.00),
       ('2','yuca', 30, 5000.00),
       ('3','arroz', 50, 2500.00);

insert into pedidos (fecha, cantidad, valor_total, producto_id, cliente_id) 
values ('2024-08-23', 3 , 75000.00, '1', '2'),
       ('2024-08-24', 1 , 5000.00, '2', '2'),
       ('2024-08-25', 2 , 5000.00, '3', '3');

update clientes 
set nombre = 'juan' 
where identificacion = '1';

update clientes 
set correo = 'pepitonuevoc@gmail.com' 
where identificacion = '2';

update productos 
set nombre = 'pollo asado' 
where codigo = '1';

update productos 
set stock = 100 
where codigo = '2';

update pedidos 
set fecha = '2024-08-30' 
where id = 1;

update pedidos 
set valor_total = 752.00 
where id = 2;

delete from pedidos 
where id = 2;

delete from productos 
where codigo = '2';

delete from clientes 
where identificacion = '2';

rollback;
