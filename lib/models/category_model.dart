/// Category Model 
class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final String? parentCategoryId;
  final CategoryModel? parentCategory; 
  final int productCount;
  final List<CategoryModel> children; 
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    this.parentCategoryId,
    this.parentCategory,
    this.productCount = 0,
    this.children = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      description: json['description'],
      parentCategoryId: json['parentCategory'] is String
          ? json['parentCategory']
          : json['parentCategory']?['_id'],
      parentCategory: json['parentCategory'] is Map
          ? CategoryModel.fromJson(json['parentCategory'])
          : null,
      productCount: json['productCount'] ?? 0,
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => CategoryModel.fromJson(child))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'image': image,
      'description': description,
      'parentCategory': parentCategoryId,
      'productCount': productCount,
      if (children.isNotEmpty)
        'children': children.map((c) => c.toJson()).toList(),
    };
  }

  /// Check if this is a parent category
  bool get isParent => parentCategoryId == null;

  /// Check if this is a subcategory
  bool get isSubcategory => parentCategoryId != null;

  /// Check if this category has children
  bool get hasChildren => children.isNotEmpty;

  /// Get full image URL
  String getFullImageUrl(String baseUrl) {
    if (image == null || image!.isEmpty) {
      return 'https://via.placeholder.com/150?text=${Uri.encodeComponent(name)}';
    }
    if (image!.startsWith('http')) return image!;
    return '$baseUrl/$image';
  }

  /// Copy with new values
  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? image,
    String? description,
    String? parentCategoryId,
    CategoryModel? parentCategory,
    int? productCount,
    List<CategoryModel>? children,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      parentCategory: parentCategory ?? this.parentCategory,
      productCount: productCount ?? this.productCount,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
