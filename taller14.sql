create table libros (
	isbn varchar primary key,
	descripcion xml
);

BEGIN;

INSERT INTO libros (isbn, descripcion) VALUES 
('978-3-16-148410-0', '<libros><libro><titulo>El Quijote</titulo><autor>Miguel de Cervantes</autor><anio>1932</anio></libro></libros>'),
('978-0-14-044913-6', '<libros><libro><titulo>Odisea</titulo><autor>Homero</autor><anio>2000</anio></libro></libros>'),
('978-0-7432-7356-5', '<libros><libro><titulo>El Gran Gatsby</titulo><autor>F. Scott Fitzgerald</autor><anio>1925</anio></libro></libros>'),
('978-0-452-28423-4', '<libros><libro><titulo>1984</titulo><autor>George Orwell</autor><anio>1949</anio></libro></libros>'),
('978-0-670-81302-4', '<libros><libro><titulo>Moby Dick</titulo><autor>Herman Melville</autor><anio>1851</anio></libro></libros>'),
('978-1-56619-909-4', '<libros><libro><titulo>Hamlet</titulo><autor>William Shakespeare</autor><anio>1603</anio></libro></libros>'),
('978-0-14-143951-8', '<libros><libro><titulo>Jane Eyre</titulo><autor>Charlotte Brontë</autor><anio>1847</anio></libro></libros>'),
('978-0-7432-7357-2', '<libros><libro><titulo>La Metamorfosis</titulo><autor>Franz Kafka</autor><anio>1915</anio></libro></libros>'),
('978-0-06-093546-7', '<libros><libro><titulo>To Kill a Mockingbird</titulo><autor>Harper Lee</autor><anio>1960</anio></libro></libros>'),
('978-0-14-303943-3', '<libros><libro><titulo>Anna Karenina</titulo><autor>Leon Tolstoy</autor><anio>1877</anio></libro></libros>'),
('978-0-679-73232-7', '<libros><libro><titulo>El Retrato de Dorian Gray</titulo><autor>Oscar Wilde</autor><anio>1890</anio></libro></libros>'),
('978-0-312-42773-3', '<libros><libro><titulo>Cumbres Borrascosas</titulo><autor>Emily Brontë</autor><anio>1847</anio></libro></libros>'),
('978-0-06-112241-5', '<libros><libro><titulo>El guardián entre el centeno</titulo><autor>J.D. Salinger</autor><anio>1951</anio></libro></libros>'),
('978-0-00-730042-2', '<libros><libro><titulo>Orgullo y Prejuicio</titulo><autor>Jane Austen</autor><anio>1813</anio></libro></libros>'),
('978-0-14-118506-4', '<libros><libro><titulo>Ulises</titulo><autor>James Joyce</autor><anio>1922</anio></libro></libros>'),
('978-0-553-21311-7', '<libros><libro><titulo>Fahrenheit 451</titulo><autor>Ray Bradbury</autor><anio>1953</anio></libro></libros>'),
('978-0-14-143955-6', '<libros><libro><titulo>Drácula</titulo><autor>Bram Stoker</autor><anio>1897</anio></libro></libros>'),
('978-0-14-243727-8', '<libros><libro><titulo>Frankenstein</titulo><autor>Mary Shelley</autor><anio>1818</anio></libro></libros>'),
('978-0-14-043919-9', '<libros><libro><titulo>Crimen y Castigo</titulo><autor>Fiódor Dostoyevski</autor><anio>1866</anio></libro></libros>'),
('978-0-14-044926-6', '<libros><libro><titulo>Guerra y Paz</titulo><autor>Leon Tolstoy</autor><anio>1869</anio></libro></libros>'),
('978-0-19-283374-2', '<libros><libro><titulo>Los Miserables</titulo><autor>Victor Hugo</autor><anio>1862</anio></libro></libros>'),
('978-0-14-044918-1', '<libros><libro><titulo>El Conde de Montecristo</titulo><autor>Alexandre Dumas</autor><anio>1844</anio></libro></libros>'),
('978-0-19-953556-9', '<libros><libro><titulo>El Proceso</titulo><autor>Franz Kafka</autor><anio>1925</anio></libro></libros>'),
('978-0-14-018639-0', '<libros><libro><titulo>Corazón de Tinieblas</titulo><autor>Joseph Conrad</autor><anio>1899</anio></libro></libros>'),
('978-0-375-70120-0', '<libros><libro><titulo>En busca del tiempo perdido</titulo><autor>Marcel Proust</autor><anio>1913</anio></libro></libros>'),
('978-0-14-044792-7', '<libros><libro><titulo>Los hermanos Karamazov</titulo><autor>Fiódor Dostoyevski</autor><anio>1880</anio></libro></libros>'),
('978-0-14-143959-4', '<libros><libro><titulo>Las aventuras de Huckleberry Finn</titulo><autor>Mark Twain</autor><anio>1884</anio></libro></libros>'),
('978-0-7432-7359-6', '<libros><libro><titulo>El extranjero</titulo><autor>Albert Camus</autor><anio>1942</anio></libro></libros>'),
('978-0-452-28425-8', '<libros><libro><titulo>Brave New World</titulo><autor>Aldous Huxley</autor><anio>1932</anio></libro></libros>'),
('978-0-553-21312-4', '<libros><libro><titulo>Un mundo feliz</titulo><autor>Aldous Huxley</autor><anio>1932</anio></libro></libros>');

COMMIT;

/* PUNTO 1 */

create or replace procedure actividadxml.guardar_libro(
p_isnb varchar, p_descripcion text)
language plpgsql
as $$
declare 
v_titulo text; 
v_isbn varchar;
v_description_titulo text; 
v_description xml;
begin 
	v_description :=xmlparse(document p_descripcion);
	select isbn into v_isbn from actividadxml.libros where isbn = p_isnb;
	if v_isbn is not null then
		raise notice 'ya existe un libro con el isbn ingresado';
	else 
		select unnest(xpath('//titulo/text()', v_description))::text into v_description_titulo;
		select l.titulo into v_titulo from actividadxml.libros, xmltable('//libro' passing descripcion columns titulo text path 'titulo')
 		as l where l.titulo = v_description_titulo;
	 	if v_titulo is not null then
			raise notice 'Lirbo existente'; 
		else  
		insert into actividadxml.libros (isbn, descripcion) values (p_isnb, v_description); 
			raise notice 'se agrego el libro';
		end if;
	end if;
end;
$$


/* PUNTO 2 */
create or replace procedure actividadxml.actualizar_libro(
p_isnb varchar, p_descripcion text)
language plpgsql
as $$
declare 
v_descripcion xml;
begin
	v_descripcion :=  xmlparse(document p_descripcion);
	update actividadxml.libros set descripcion = v_descripcion where isbn = p_isnb;
end;
$$

/* PUNTO 3 */

create or replace function actividadxml.obtener_autor_libro_por_isbn(
p_isbn varchar) 
returns text 
language plpgsql
as
$$
declare
	v_autor text;
begin 
select unnest(xpath('//autor/text()',descripcion))::text into v_autor from actividadxml.libros where isbn = p_isbn;
return v_autor;
end;
$$

/* PUNTO 4 */

create or replace function actividadxml.obtener_libros_por_titulo(
p_titulo text) 
returns text 
language plpgsql
as
$$
declare
	v_autor text;
begin
select l.autor into v_autor from actividadxml.libros,
    xmltable(
        '//libro'
        passing descripcion
        columns
            titulo text path 'titulo', 
            autor text path 'autor'
    ) as l where l.titulo = p_titulo; 

return v_autor;
end;
$$

/* PUNTO 5 */

create or replace function actividadxml.obtener_libros_por_anio(
p_anio text) 
returns table(
    isbn varchar,
    titulo text,
    autor text,
    anio text
) 
language plpgsql
as
$$
begin 
    return QUERY 
    select 
        libros.isbn,
        l.titulo,
        l.autor,
        l.anio
    from actividadxml.libros,
    xmltable(
        '//libro'
        passing descripcion
        columns
            titulo text path 'titulo', 
            autor text path 'autor', 
            anio text path 'anio'
    ) as l
    where l.anio = p_anio;
end;
$$;




