package org.example;


import com.mongodb.client.*;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;

import static com.mongodb.client.MongoClients.create;
import static com.mongodb.client.model.Filters.eq;

public class Main {
    public static void main(String[] args) {
        try{
            String uri = "mongodb://localhost:27017";
            MongoClient mongoClient = create(uri);
            MongoDatabase database = mongoClient.getDatabase("parcial");
            MongoCollection<Document> collectionPedidos = database.getCollection("pedidos");
            MongoCollection<Document> collectionProductos = database.getCollection("productos");
            MongoCollection<Document> collectionDetalles = database.getCollection("detalle_pedidos");

            //PUNTO 1
            //PRODUCTOS

            Productos producto = new Productos();
            producto.crear_producto(collectionProductos, "producto001", "papa", "salada", 13.2F, 4);
            producto.obtener_producto(collectionProductos, "producto001");
            producto.actualizar_producto(collectionProductos, "producto001", "papa frita", "salada", 13.2F, 4);
            producto.eliminar_producto(collectionProductos, "producto001");

            //PEDIDOS
            Pedidos pedido = new Pedidos();
            pedido.crear_pedido(collectionPedidos, "pedido001", "cliente001", "2024-12-02T14:00:00Z", "Enviado", 31.98F);
            pedido.obtener_pedido(collectionPedidos, "pedido001");
            pedido.actualizar_pedido(collectionPedidos, "pedido001", "cliente001", "2024-12-02T14:00:00Z", "Recibido", 31.98F);
            pedido.eliminar_pedido(collectionPedidos, "pedido001");

            //DETALLE PEDIDO
            DetallePedidos detalle = new DetallePedidos();
            detalle.crear_detalle(collectionDetalles, collectionProductos, collectionPedidos, "detalle001", "pedido001", "producto001", 2, 15.99f);
            detalle.obtener_detalle(collectionDetalles, "detalle001");
            detalle.actualizar_detalle(collectionDetalles, "detalle001", "pedido001", "producto001", 3, 15.99f);
            detalle.eliminar_detalle(collectionDetalles, "detalle001");

            //PUNTO 2
            producto.crear_producto(collectionProductos, "producto002", "yuca", "salada", 21F, 4);
            producto.obtener_producto_precio(collectionProductos);

            pedido.crear_pedido(collectionPedidos, "pedido002", "cliente001", "2024-12-02T14:00:00Z", "Enviado", 105F);
            pedido.obtener_pedido_total(collectionPedidos);

            //En lugar de usar el producto010 use el producto002 porque lo cree justo arriba y me dio pereza xd
            detalle.crear_detalle(collectionDetalles, collectionProductos, collectionPedidos, "detalle001", "pedido001", "producto002", 2, 15.99f);
            detalle.obtener_detalle_pedido_especifico(collectionDetalles);


        }catch (Exception e) {
            throw new RuntimeException(e);
        }

    }
}