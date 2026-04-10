import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SALVAR: Adiciona um novo produto
  Future<void> addProduct(String name, double price) async {
    await _db.collection('products').add({
      'name': name,
      'price': price,
      'isBought': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // LER: Retorna um "Stream" que atualiza a tela sozinho quando o dado muda
  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList());
  }

  // DELETAR: Remove um produto pelo ID
  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }
}