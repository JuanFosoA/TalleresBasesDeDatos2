package org.example;

import java.math.BigDecimal;
import java.sql.*;

public class Transacciones_total {
    public static void main(String[] args) throws SQLException {
        try {
            String url = "jdbc:postgresql://localhost:5432/postgres?user=postgres&password=ellenjoe";
            Connection conn = DriverManager.getConnection(url);

            /* Conexión simular_ventas_mes taller 5 */
            CallableStatement transacciones_total_mes = conn.prepareCall("{? = call funcionesalmacenadas.transacciones_total_mes(?, ?)}");
            transacciones_total_mes.registerOutParameter(1, Types.NUMERIC);
            transacciones_total_mes.setString(2, "xGxpy7huwl ");
            transacciones_total_mes.setInt(3, 7);
            transacciones_total_mes.execute();
            BigDecimal resultado_transacciones = transacciones_total_mes.getBigDecimal(1);
            System.out.println("Transcciones total en el mes: "+ resultado_transacciones);
            transacciones_total_mes.close();
            conn.close();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
