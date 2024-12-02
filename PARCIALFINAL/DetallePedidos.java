package org.example;

import com.mongodb.client.MongoCollection;

import static com.mongodb.client.model.Updates.set;
import static com.mongodb.client.model.Filters.*;

import com.mongodb.client.MongoCursor;
import org.bson.Document;

public class DetallePedidos {

    //crear detalle
    public void crear_detalle(MongoCollection<Document> collectionDetalle, MongoCollection<Document> collectionProducto,
                              MongoCollection<Document> collectionPedido,
                             String _id, String pedido_id, String producto_id, int cantidad, float precio_unitario){

        Document detalle = new Document("_id", _id).append("pedido_id", pedido_id).append("producto_id", producto_id)
                .append("cantidad", cantidad).append("precio_unitario", precio_unitario);
        try {

            collectionDetalle.insertOne(detalle);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //eliminar detalle
    public void eliminar_detalle(MongoCollection<Document> collection, String _id ){
        try{
            collection.deleteOne(eq("_id", _id));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //actualizar detalle
    public void actualizar_detalle(MongoCollection<Document> collection,
                                   String _id, String pedido_id, String producto_id, int cantidad, float precio_unitario){

        try{
            collection.updateOne(eq("_id", _id), set("pedido_id", pedido_id));
            collection.updateOne(eq("_id", _id), set("producto_id", producto_id));
            collection.updateOne(eq("_id", _id), set("cantidad", cantidad));
            collection.updateOne(eq("_id", _id), set("precio_unitario", precio_unitario));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //obtener detalle
    public void obtener_detalle(MongoCollection<Document> collection, String _id){
        try{
            MongoCursor<Document> cursor = collection.find(eq("_id", _id)).iterator();
            while (cursor.hasNext()){
                System.out.println(cursor.next().toJson());
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //obtener detalle pedido con pedido especifico
    public void obtener_detalle_pedido_especifico(MongoCollection<Document> collection){
        try{
            MongoCursor<Document> cursor = collection.find(eq("producto_id", "producto002")).iterator();
            while (cursor.hasNext()){
                System.out.println(cursor.next().toJson());
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

}
