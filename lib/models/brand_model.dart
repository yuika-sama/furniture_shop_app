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
      id: json['_id'] ?? '',

      name: json['name'] ?? '',
      slug: json['slug'] ?? '',

      image: json['image'],
      description: json['description'],

      productCount: json['productCount'] ?? 0,

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
      return 'https://via.placeholder.com/150'; 
    }
    if (image!.startsWith('http')) return image!; 
    return '$baseUrl/$image';
  }
}