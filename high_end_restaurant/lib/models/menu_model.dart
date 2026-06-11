class MenuModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;

  MenuModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
  });

  factory MenuModel.fromMap(String id, Map<String, dynamic> data) {
    return MenuModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
    };
  }
}