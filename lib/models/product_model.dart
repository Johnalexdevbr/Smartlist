class Product {
  String id;
  String name;
  double price;
  bool isBought;

  Product({required this.id, required this.name, required this.price, this.isBought = false});

  // Converte o que vem do Firebase (JSON) para o nosso objeto Product
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      isBought: map['isBought'] ?? false,
    );
  }

  // Converte o nosso objeto para JSON para enviar ao Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'isBought': isBought,
      'timestamp': DateTime.now(), // Bom para ordenar a lista
    };
  }
}