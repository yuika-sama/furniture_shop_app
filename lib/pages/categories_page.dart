import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../components/app_bar_actions.dart';
import '../components/room_category_components.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final categoryProvider = context.read<CategoryProvider>();
    await Future.wait([
      categoryProvider.loadCategoryTree(),
      categoryProvider.loadCategories(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Danh mục'),
              floating: true,
              snap: true,
              actions: [
                CommonAppBarActions(
                  showWishlist: false,
                  additionalActions: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                tabs: const [
                  Tab(text: 'Theo phòng'),
                  Tab(text: 'Theo loại'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildRoomsList(),
            _buildCategoriesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (provider.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 80,
                  color: AppTheme.char300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có danh mục nào',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.char500,
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return Card(
                child: ListTile(
                  leading: category.image != null && category.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            category.image!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.category,
                                  color: AppTheme.primary500,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primary100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.category,
                            color: AppTheme.primary500,
                          ),
                        ),
                  title: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category.description != null && category.description!.isNotEmpty)
                        Text(
                          category.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.char600,
                              ),
                        ),
                      if (category.parentCategory != null)
                        Text(
                          'Thuộc: ${category.parentCategory!.name}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primary500,
                                fontSize: 11,
                              ),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to category products
                    debugPrint('Tapped on category: ${category.name}');
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRoomsList() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final rootCategories = provider.rootCategories;

        if (rootCategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 80,
                  color: AppTheme.char300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có danh mục nào',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.char500,
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: rootCategories.length,
            itemBuilder: (context, roomIndex) {
              final room = rootCategories[roomIndex];
              
              return Column(
                children: [
                  // Room Banner
                  RoomBanner(
                    title: room.name,
                    subtitle: room.description ?? 'Khám phá các sản phẩm',
                    imagePath: room.image ?? '',
                    onViewProducts: () {
                      // TODO: Navigate to all products in this room
                      debugPrint('View all products for ${room.name}');
                    },
                  ),
                  
                  // Furniture Types Grid (subcategories)
                  if (room.children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: room.children.length,
                        itemBuilder: (context, index) {
                          final subcategory = room.children[index];
                          return FurnitureTypeCard(
                            title: subcategory.name,
                            imagePath: subcategory.image ?? '',
                            onTap: () {
                              // TODO: Navigate to products of this furniture type
                              debugPrint('Tapped on ${subcategory.name} in ${room.name}');
                            },
                          );
                        },
                      ),
                    ),
                  
                  // Spacing between rooms
                  SizedBox(height: roomIndex < rootCategories.length - 1 ? 24 : 80),
                ],
              );
            },
          ),
        );
      },
    );
  }



  Widget _buildOldRoomsList() {
    final rooms = [
      {
        'name': 'Phòng khách',
        'icon': Icons.weekend,
        'description': 'Sofa, bàn trà, kệ TV',
        'image': Icons.living
      },
      {
        'name': 'Phòng ngủ',
        'icon': Icons.bed,
        'description': 'Giường, tủ quần áo, bàn trang điểm',
        'image': Icons.bedroom_parent
      },
      {
        'name': 'Nhà bếp',
        'icon': Icons.kitchen,
        'description': 'Tủ bếp, bàn ăn, ghế ăn',
        'image': Icons.dining
      },
      {
        'name': 'Phòng làm việc',
        'icon': Icons.desk,
        'description': 'Bàn làm việc, ghế văn phòng, tủ hồ sơ',
        'image': Icons.business_center
      },
      {
        'name': 'Phòng tắm',
        'icon': Icons.bathtub,
        'description': 'Tủ lavabo, gương, kệ',
        'image': Icons.bathroom
      },
      {
        'name': 'Ban công',
        'icon': Icons.balcony,
        'description': 'Ghế ngoài trời, bàn cafe',
        'image': Icons.deck
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // TODO: Navigate to room products
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: AppTheme.beige100,
                    child: Center(
                      child: Icon(
                        room['image'] as IconData,
                        size: 64,
                        color: AppTheme.primary400,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            room['icon'] as IconData,
                            size: 20,
                            color: AppTheme.primary500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              room['name'] as String,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.char600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ lọc',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Sắp xếp theo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Tất cả',
                  'Mới nhất',
                  'Bán chạy',
                  'Giá tăng dần',
                  'Giá giảm dần',
                  'Đánh giá cao',
                ].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      Navigator.pop(context);
                    },
                    selectedColor: AppTheme.primary100,
                    checkmarkColor: AppTheme.primary500,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary500 : AppTheme.char700,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
