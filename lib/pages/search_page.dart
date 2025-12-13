import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/product_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _recentSearches = [
    'Ghế sofa',
    'Bàn làm việc',
    'Giường ngủ',
    'Tủ quần áo',
  ];

  List<String> _popularSearches = [
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isSearching = true;
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      }
    });

    // TODO: Implement actual search with ProductProvider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _isSearching = false;
                      });
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
      body: _isSearching ? _buildSearchResults() : _buildSearchSuggestions(),
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
    final categories = [
      {'name': 'Phòng khách', 'icon': Icons.weekend, 'count': '156'},
      {'name': 'Phòng ngủ', 'icon': Icons.bed, 'count': '98'},
      {'name': 'Nhà bếp', 'icon': Icons.kitchen, 'count': '87'},
      {'name': 'Văn phòng', 'icon': Icons.desk, 'count': '124'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          child: InkWell(
            onTap: () {
              // TODO: Navigate to category
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 32,
                    color: AppTheme.primary500,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'] as String,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${category['count']} sản phẩm',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.char500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    // Mock search results
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Kết quả tìm kiếm cho "${_searchController.text}"',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        _buildFilterChips(),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _buildProductCard(index);
          },
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Tất cả'),
            selected: true,
            onSelected: (value) {},
            selectedColor: AppTheme.primary100,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Giá thấp đến cao'),
            selected: false,
            onSelected: (value) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Đánh giá cao'),
            selected: false,
            onSelected: (value) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Mới nhất'),
            selected: false,
            onSelected: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: AppTheme.beige100,
                  child: const Center(
                    child: Icon(
                      Icons.chair,
                      size: 64,
                      color: AppTheme.primary300,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '-20%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sản phẩm ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₫${((index + 1) * 800000).toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.char500,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '₫${((index + 1) * 640000).toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary500,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppTheme.warning,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '4.5',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${(index + 1) * 10})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.char500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
