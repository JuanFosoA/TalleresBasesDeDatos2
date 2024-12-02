package org.example;

import com.mongodb.client.MongoCollection;

import static com.mongodb.client.model.Updates.set;
import static com.mongodb.client.model.Filters.*;

import com.mongodb.client.MongoCursor;
import org.bson.Document;

public class Productos {

    //crear producto
    public void crear_producto(MongoCollection<Document> collection,
                                  String _id, String nombre, String descripcion, float precio, int stock){

        Document producto = new Document("_id", _id).append("nombre", nombre).append("descripcion", descripcion)
                .append("precio", precio).append("stock", stock);
        try {
            collection.insertOne(producto);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //eliminar producto
    public void eliminar_producto(MongoCollection<Document> collection, String _id ){
        try{
            collection.deleteOne(eq("_id", _id));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //actualizar producto
    public void actualizar_producto(MongoCollection<Document> collection,
                                    String _id, String nombre, String descripcion, float precio, int stock){

        try{
            collection.updateOne(eq("_id", _id), set("nombre", nombre));
            collection.updateOne(eq("_id", _id), set("descripcion", descripcion));
            collection.updateOne(eq("_id", _id), set("precio", precio));
            collection.updateOne(eq("_id", _id), set("stock", stock));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //obtener producto
    public boolean obtener_producto(MongoCollection<Document> collection, String _id){
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

    // obtener por precio
    public boolean obtener_producto_precio(MongoCollection<Document> collection){
        try{
            MongoCursor<Document> cursor = collection.find(gt("precio", 20)).iterator();
            while (cursor.hasNext()){
                System.out.println(cursor.next().toJson());
            }
            return true;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
