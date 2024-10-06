create table tipo_contrato (
    id varchar(10) primary key,
    descripcion varchar(250) not null,
    cargo varchar(75),
    salario_total numeric
);

create table empleados (
    identificacion varchar(10) primary key,
    nombre varchar(65) not null,
    tipo_contrato_id varchar(10),
    foreign key (tipo_contrato_id) references tipo_contrato(id)
);

create type nombre_concepto as enum ('salario', 'horas_extras', 'prestaciones', 'impuestos');

create table conceptos (
    id varchar(10) primary key,
    nombre nombre_concepto not null,
    porcentaje numeric
);

create table nomina (
    id serial primary key,
    fecha_pago date not null,
    total_devengado numeric,
    total_deducciones numeric,
    total numeric,
    empleado_id varchar(10),
    foreign key (empleado_id) references empleados(identificacion)
);


create table detalles_nomina (
    id SERIAL primary key,
    nomina_id integer,
    concepto_id varchar(10),
    valor numeric NOT NULL,
    FOREIGN KEY (nomina_id) REFERENCES nomina(id),
    FOREIGN KEY (concepto_id) REFERENCES conceptos(id)
);


/* Primera parte: Poblar las tablas  */
create or replace procedure poblar_tipo_contrato()
language plpgsql
as $$
declare
    v_i integer;
begin
    for v_i in 1..10 loop
        insert into tipo_contrato (id, descripcion, cargo, salario_total)
        values ('contrato' || i, 'Descripción Contrato ' || i, 'Cargo ' || i, 1000 + i * 500);
    end loop;
end;
$$;

call poblar_tipo_contrato();


create or replace procedure poblar_empleados()
language plpgsql
as $$
declare
    v_i integer;
begin
    for v_i in 1..10 loop
        insert into empleados (identificacion, nombre, tipo_contrato_id)
        values ('CC' || i, 'Empleado ' || i, 'contrato' || (i % 10 + 1)); 
    end loop;
end;
$$;

call poblar_empleados();


create or replace procedure poblar_conceptos()
language plpgsql
as $$
declare
    v_i integer;
    v_nombres_conceptos nombre_concepto[] := array['salario', 'horas_extras', 'prestaciones', 'impuestos'];
begin
    for v_i in 1..15 loop
        insert into conceptos (id, nombre, porcentaje)
        values ('conc' || lpad(v_i::text, 3, '0'), 
                v_nombres_conceptos[(v_i % 4) + 1], 
                round((random() * 20)::numeric, 2));
    end loop;
end;
$$;

call poblar_conceptos();


create or replace procedure poblar_nomina()
language plpgsql
as $$
declare
    v_i integer;
    v_mes integer;
begin
    for v_i in 1..5 loop
        v_mes := 6 + (v_i - 1);
        insert into nomina (fecha_pago, total_devengado, total_deducciones, total, empleado_id)
        values (MAKE_DATE(2024, v_mes, 1),
                ROUND(CAST(2000 + RANDOM() * 3000 AS numeric), 2),
                ROUND(CAST(100 + RANDOM() * 500 AS numeric), 2),  
                ROUND(CAST((2000 + RANDOM() * 3000) - (100 + RANDOM() * 500) AS numeric), 2),
                'CC' || v_i);
    end loop;
end;
$$;

call poblar_nomina();


create or replace procedure poblar_detalles_nomina()
language plpgsql
as $$
declare
    i int;
begin
    for i in 1..15 loop
        insert into detalles_nomina (nomina_id, concepto_id, valor)
        values (
            (i % 5) + 1,
            'conc' || lpad(((i % 15) + 1)::text, 3, '0'), 
            round(cast(100 + random() * 1000 as numeric), 2)
        );
    end loop;
end;
$$;


call poblar_detalles_nomina();

/* Parte dos ejercicios con return Query */


create or replace function obtener_nomina_empleado(
	p_identificacion varchar,
	p_mes integer,
	p_anio integer
)
returns table (
    v_nombre_empleado varchar,
    v_total_devengado numeric,
    v_total_deducido numeric,
    v_total_nomina numeric
) as $$
begin
    return query
    select e.nombre, n.total_devengado, n.total_deducciones, n.total
    from empleados e
    join nomina n on e.identificacion = n.empleado_id
    where e.identificacion = p_identificacion
    and extract(month from n.fecha_pago) = p_mes
    and extract(year from n.fecha_pago) = p_anio;
end;
$$ 
language plpgsql;


select obtener_nomina_empleado('CC1', 6, 2024);


create or replace function total_por_contrato(
    p_tipo_contrato varchar
)
returns table (
    v_nombre_empleado varchar,
    v_fecha_pago date,
    v_anio int,
    v_mes int,
    v_total_devengado numeric,
    v_total_deducido numeric,
    v_total_nomina numeric
) as $$
begin
    return query
    select e.nombre, n.fecha_pago, 
           cast(extract(year from n.fecha_pago) as int) as v_anio, 
           cast(extract(month from n.fecha_pago) as int) as v_mes,
           n.total_devengado, n.total_deducciones, n.total
    from empleados e
    join nomina n on e.identificacion = n.empleado_id
    join tipo_contrato tc on e.tipo_contrato_id = tc.id
    where tc.id = p_tipo_contrato;
end;
$$ 
language plpgsql;


select total_por_contrato('contrato2');








