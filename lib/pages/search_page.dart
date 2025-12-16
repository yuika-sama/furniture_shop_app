import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/category_model.dart';
import '../service/category_service.dart';
import '../service/api_client.dart';
import 'products_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final CategoryService _categoryService;

  bool _isLoadingCategories = true;
  List<CategoryModel> _categories = [];

  final List<String> _recentSearches = [
    'Ghế sofa',
    'Bàn làm việc',
    'Giường ngủ',
    'Tủ quần áo',
  ];

  final List<String> _popularSearches = [
    'Bàn ăn gỗ',
    'Ghế văn phòng',
    'Kệ tivi',
    'Sofa góc',
    'Giường ngủ đôi',
    'Tủ bếp',
    'Bàn trang điểm',
    'Ghế thư giãn',
  ];

  @override
  void initState() {
    super.initState();
    _categoryService = CategoryService(ApiClient());
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _categoryService.getAllCategories();
      if (result['success'] == true && mounted) {
        setState(() {
          _categories = result['categories'] ?? [];
          _isLoadingCategories = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  IconData _getCategoryIcon(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('phòng khách') || nameLower.contains('living')) {
      return Icons.weekend;
    } else if (nameLower.contains('phòng ngủ') || nameLower.contains('bedroom') || nameLower.contains('giường')) {
      return Icons.bed;
    } else if (nameLower.contains('nhà bếp') || nameLower.contains('kitchen') || nameLower.contains('bếp')) {
      return Icons.kitchen;
    } else if (nameLower.contains('văn phòng') || nameLower.contains('office') || nameLower.contains('bàn làm việc')) {
      return Icons.desk;
    } else if (nameLower.contains('phòng ăn') || nameLower.contains('dining')) {
      return Icons.dining;
    } else if (nameLower.contains('phòng tắm') || nameLower.contains('bathroom')) {
      return Icons.bathtub;
    } else {
      return Icons.chair;
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      if (_recentSearches.contains(query)) {
        _recentSearches.remove(query);
      }
      _recentSearches.insert(0, query);

      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsPage(
          searchQuery: query,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppTheme.char900),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            hintStyle: TextStyle(color: AppTheme.char900.withOpacity(0.7)),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.char900),
              onPressed: () {
                _searchController.clear();
                setState(() {}); 
              },
            )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _performSearch(_searchController.text);
            },
          ),
        ],
      ),
      body: _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tìm kiếm gần đây',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: const Text('Xóa tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._recentSearches.map((search) => ListTile(
              contentPadding: EdgeInsets.zero, // Tối ưu padding
              leading: const Icon(Icons.history, color: AppTheme.char500),
              title: Text(search),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _recentSearches.remove(search);
                  });
                },
              ),
              onTap: () {
                _searchController.text = search;
                _performSearch(search);
              },
            )),
            const SizedBox(height: 24),
          ],

          Text(
            'Tìm kiếm phổ biến',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) {
              return ActionChip(
                label: Text(search),
                backgroundColor: AppTheme.beige100,
                side: const BorderSide(color: Colors.transparent),
                onPressed: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          Text(
            'Danh mục nổi bật',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_isLoadingCategories) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text("Không có danh mục nào"),
      );
    }

    final displayCategories = _categories.take(4).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayCategories.length,
      itemBuilder: (context, index) {
        final category = displayCategories[index];
        return Card(
          elevation: 2, // Thêm chút bóng đổ cho đẹp
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsPage(
                    categoryId: category.id,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getCategoryIcon(category.name),
                    size: 32,
                    color: AppTheme.primary500,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.productCount} sản phẩm',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.char500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}