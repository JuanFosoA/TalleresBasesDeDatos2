package org.example;

import com.mongodb.client.MongoCollection;

import static com.mongodb.client.model.Updates.set;
import static com.mongodb.client.model.Filters.*;

import com.mongodb.client.MongoCursor;
import org.bson.Document;


public class Pedidos {
    //crear pedidos
    public void crear_pedido(MongoCollection<Document> collection,
                               String _id, String cliente, String fecha_pedido, String estado, float total){

        Document pedido = new Document("_id", _id).append("cliente", cliente).append("fecha_pedido", fecha_pedido)
                .append("estado", estado).append("total", total);
        try {
            collection.insertOne(pedido);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //eliminar pedidos
    public void eliminar_pedido(MongoCollection<Document> collection, String _id ){
        try{
            collection.deleteOne(eq("_id", _id));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //actualizar pedidos
    public void actualizar_pedido(MongoCollection<Document> collection,
                                  String _id, String cliente, String fecha_pedido, String estado, float total){

        try{
            collection.updateOne(eq("_id", _id), set("cliente", cliente));
            collection.updateOne(eq("_id", _id), set("fecha_pedido", fecha_pedido));
            collection.updateOne(eq("_id", _id), set("estado", estado));
            collection.updateOne(eq("_id", _id), set("total", total));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //obtener pedidos
    public boolean obtener_pedido(MongoCollection<Document> collection, String _id){
        try{
            MongoCursor<Document> cursor = collection.find(eq("_id", _id)).iterator();
            while (cursor.hasNext()){
                System.out.println(cursor.next().toJson());
            }
            return true;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //obtener pedido total
    public boolean obtener_pedido_total(MongoCollection<Document> collection){
        try{
            MongoCursor<Document> cursor = collection.find(gt("total", 100)).iterator();
            while (cursor.hasNext()){
                System.out.println(cursor.next().toJson());
            }
            return true;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }



}
