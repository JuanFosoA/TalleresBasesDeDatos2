package org.example;

import java.sql.*;

public class Taller14 {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/postgres?user=postgres&password=nuevacontraseña";
        try {
            Connection conn = DriverManager.getConnection(url);
            guardarLibro(
                    conn,
                    "978-0-141-03435-4",
                    "<libros><libro><titulo>1984</titulo><autor>George Orwell</autor><anio>1949</anio></libro></libros>");

            actualizarLibro(
                    conn,
                    "978-0-141-03435-4",
                    "<libros><libro><titulo>1984</titulo><autor>George Orwell</autor><anio>1950</anio></libro></libros>");

            String autor = obtenerAutorPorIsbn(
                    conn,
                    "978-0-141-03435-4"
            );

            System.out.println("Autor: " + autor);

            String autorPorTitulo = obtenerAutorPorTitulo(
                    conn,
                    "1984"
            );

            System.out.println("Autor por título: " + autorPorTitulo);

            obtenerLibrosPorAnio(
                    conn,
                    "1950"
            );

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void guardarLibro(Connection conn, String isbn, String descripcion) {
        String sql = "CALL actividadxml.guardar_libro(?, ?)";
        try {
            CallableStatement cstm = conn.prepareCall(sql);
            cstm.setString(1, isbn);
            cstm.setString(2, descripcion);
            cstm.execute();
            System.out.println("Libro guardado exitosamente.");
        } catch (SQLException e) {
            System.err.println("Error al guardar el libro: " + e.getMessage());
        }
    }

    private static void actualizarLibro(Connection conn, String isbn, String descripcion) {
        String sql = "CALL actividadxml.actualizar_libro(?, ?)";
        try {
            CallableStatement cstm = conn.prepareCall(sql);
            cstm.setString(1, isbn);
            cstm.setString(2, descripcion);
            cstm.execute();
            System.out.println("Libro actualizado exitosamente.");
        } catch (SQLException e) {
            System.err.println("Error al actualizar el libro: " + e.getMessage());
        }
    }

    private static String obtenerAutorPorIsbn(Connection conn, String isbn) {
        String sql = "{? = CALL actividadxml.obtener_autor_libro_por_isbn(?)}";
        try {
            CallableStatement cstm = conn.prepareCall(sql);
            cstm.registerOutParameter(1, Types.VARCHAR);
            cstm.setString(2, isbn);
            cstm.execute();
            return cstm.getString(1);
        } catch (SQLException e) {
            System.err.println("Error al obtener el autor por ISBN: " + e.getMessage());
        }
        return null;
    }

    private static String obtenerAutorPorTitulo(Connection conn, String titulo) {
        String sql = "{? = CALL actividadxml.obtener_libros_por_titulo(?)}";
        try {
            CallableStatement cstm = conn.prepareCall(sql);
            cstm.registerOutParameter(1, Types.VARCHAR);
            cstm.setString(2, titulo);
            cstm.execute();
            return cstm.getString(1);
        } catch (SQLException e) {
            System.err.println("Error al obtener el autor por título: " + e.getMessage());
        }
        return null;
    }

    private static void obtenerLibrosPorAnio(Connection conn, String anio) {
        String sql = "SELECT * FROM actividadxml.obtener_libros_por_anio(?)";
        try {
            PreparedStatement stm = conn.prepareStatement(sql);
            stm.setString(1, anio);
            ResultSet resultSet = stm.executeQuery();
            while (resultSet.next()) {
                System.out.println("ISBN: " + resultSet.getString("isbn") +
                        ", Título: " + resultSet.getString("titulo") +
                        ", Autor: " + resultSet.getString("autor") +
                        ", Año: " + resultSet.getString("anio"));
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener libros por año: " + e.getMessage());
        }
    }
}
