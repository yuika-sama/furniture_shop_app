class BrandModel {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final int productCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    this.productCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      // Backend Mongo dùng _id, map sang id của Dart
      id: json['_id'] ?? '',

      name: json['name'] ?? '',
      slug: json['slug'] ?? '',

      // Các trường optional có thể null
      image: json['image'],
      description: json['description'],

      // Trường này do Controller tính toán gộp vào
      productCount: json['productCount'] ?? 0,

      // Parse string ISO8601 từ Mongo thành DateTime
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  String getFullImageUrl(String baseUrl) {
    if (image == null || image!.isEmpty) {
      return 'https://via.placeholder.com/150'; // Ảnh mặc định nếu null
    }
    if (image!.startsWith('http')) return image!; // Đã là link online
    return '$baseUrl/$image';
  }
}