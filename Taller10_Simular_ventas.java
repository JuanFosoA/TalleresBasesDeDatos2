package org.example;

import java.sql.*;

public class Simular_ventas {
    public static void main(String[] args) throws SQLException {
        try {
            String url = "jdbc:postgresql://localhost:5432/postgres?user=postgres&password=ellenjoe";
            Connection conn = DriverManager.getConnection(url);

            /* Conexión simular_ventas_mes taller 5 */
            CallableStatement simular_ventas_mes = conn.prepareCall("call inventario.simular_ventas_mes()");
            simular_ventas_mes.execute();
            simular_ventas_mes.close();
            conn.close();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
