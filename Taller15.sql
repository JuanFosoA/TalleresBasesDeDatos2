create table actividadjson.facturas (
	codigo serial primary key,
	descripcion jsonb
);

/* PUNTO 1 */

create or replace procedure actividadjson.guardar_factura(json_datos JSONB)
as $$
begin
    if (json_datos->>'total_factura')::numeric <= 10000 and (json_datos->>'total_descuento')::numeric <= 50 then

        insert into facturas(descripcion) values (json_datos);
    end if;
end;
$$ language plpgsql;
	
call actividadjson.guardar_factura('{ 
    "cliente": "Jose",
    "identificacion": "123",
    "direccion": "1w2",
    "codigo": "c1",
    "total_descuento": "20",
    "total_factura": "100",
    "productos":
       [ 
       {
             "cantidad": 1,
             "valor": 120.0,
             "producto": 
         { 
         "nombre": "cafe",
          "descripcion": "cafe",
           "precio": 120.0,
            "categorias": 
            [ "colombia", "desayuno" ] 
                } 
            } 
        ] 
    }')

/* PUNTO DOS */
		    
create or replace procedure actividadjson.actualizar_json_factura(
	p_codigo integer, 
	p_descripcion jsonb
)
as $$
begin
	update actividadjson.facturas
	set descripcion = p_descripcion where codigo = p_codigo;
end;
$$ language plpgsql;


call actividadjson.actualizar_json_factura(2, 
							'{ 
    "cliente": "",
    "identificacion": "",
    "direccion": "",
    "codigo": "",
    "total_descuento": "",
    "total_factura": "",
    "productos":
       [ 
       {
             "cantidad": 0,
             "valor": 0.0,
             "producto": 
         { 
         "nombre": "",
          "descripcion": "",
           "precio": 0.0,
            "categorias": 
            [ "categoria1", "categoria2", "categoria3" ] 
                } 
            } 
        ] 
    } 
}');


/* PUNTO TRES */
create or replace function actividadjson.obtener_nombre(p_identificacion text) returns text
language plpgsql
as $$
declare 
    v_nombre text;
begin
    select descripcion->> 'cliente' as cliente into v_nombre from facturas where descripcion->>'identificacion' = p_identificacion;
    return v_nombre;
end;
$$


select actividadjson.obtener_nombre('123');


/* PUNTO CUATRO */
		  
create or replace function actividadjson.obtener_informacion_cliente()
returns table (p_cliente varchar, p_identificacion varchar, p_codigo varchar,
			   p_t_descuento numeric, p_t_factura numeric)
as $$
begin
	return query
	select (descripcion->>'cliente')::varchar as cliente, (descripcion->>'identificacion')::varchar as identificacion,
	(descripcion->>'codigo')::varchar as codigo, (descripcion->>'total_descuento')::numeric as total_descuento,
	(descripcion->>'total_factura')::numeric as total_factura
	from actividadjson.facturas;
end;
$$ language plpgsql;
		   
		   
select * from actividadjson.obtener_informacion_cliente();
		

/* PUNTO CINCO */
		   
create or replace function actividadjson.obtener_productos_por_codigo_factura(p_codigo_factura varchar)
returns table (
    p_nombre_producto varchar,
    p_descripcion_producto varchar,
    p_precio_producto numeric,
    p_cantidad_producto int,
    p_valor_producto numeric
)
as $$
begin
    return query
    select 
        (p->'producto'->>'nombre')::varchar as nombre_producto,
        (p->'producto'->>'descripcion')::varchar as descripcion_producto,
        (p->'producto'->>'precio')::numeric as precio_producto,
        (p->>'cantidad')::int as cantidad_producto,
        (p->>'valor')::numeric as valor_producto
    from actividadjson.facturas f,
    json_array_elements(f.descripcion::json->'productos') as p
    where f.descripcion->>'codigo' = p_codigo_factura;
end;
$$ language plpgsql;


		   
select * from actividadjson.obtener_productos_por_codigo_factura('c1');		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   

