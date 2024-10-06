package org.example;

import java.sql.*;


public class Generar_auditoria {
    public static void main(String[] args) throws SQLException {
        try {
            String url = "jdbc:postgresql://localhost:5432/postgres?user=postgres&password=ellenjoe";
            Connection conn = DriverManager.getConnection(url);
            /* Conexión a Generar_auditoria taller 5  */
            CallableStatement generar_auditoria = conn.prepareCall("call inventario.generar_auditoria(?, ?   )");
            Date fecha_inicio = Date.valueOf("2024-08-29");
            Date fecha_fin = Date.valueOf("2024-09-2");
            generar_auditoria.setDate(1, fecha_inicio);
            generar_auditoria.setDate(2, fecha_fin);
            generar_auditoria.execute();
            generar_auditoria.close();
            conn.close();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}