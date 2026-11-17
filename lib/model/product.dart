class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final String image;
  final num price;

  //Constructeur avec les paramètres nommés "required"
  Product({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.category,
    required this.description,
  });
  String getPrice() => "${price.toStringAsFixed(2)}€";

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'description': this.description,
      'category': this.category,
      'image': this.image,
      'price': this.price,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      image: map['image'] as String,
      price: map['price'] as num,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          category == other.category &&
          image == other.image &&
          price == other.price;

  @override
  int get hashCode =>
      Object.hash(id, title, description, category, image, price);
}
