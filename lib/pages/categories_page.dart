import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/product_provider.dart';
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
                  Tab(text: 'Theo loại'),
                  Tab(text: 'Theo phòng'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCategoriesList(),
            _buildRoomsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    final categories = [
      {'name': 'Bàn', 'icon': Icons.table_bar, 'count': 45},
      {'name': 'Ghế', 'icon': Icons.chair, 'count': 67},
      {'name': 'Tủ', 'icon': Icons.shelves, 'count': 34},
      {'name': 'Giường', 'icon': Icons.bed, 'count': 28},
      {'name': 'Sofa', 'icon': Icons.weekend, 'count': 52},
      {'name': 'Đèn', 'icon': Icons.lightbulb, 'count': 89},
      {'name': 'Kệ', 'icon': Icons.kitchen, 'count': 41},
      {'name': 'Nệm', 'icon': Icons.bed_outlined, 'count': 19},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category['icon'] as IconData,
                color: AppTheme.primary500,
              ),
            ),
            title: Text(
              category['name'] as String,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text('${category['count']} sản phẩm'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to category products
            },
          ),
        );
      },
    );
  }

  Widget _buildRoomsList() {
    // All rooms data with banner images and furniture types
    final allRooms = [
      {
        'title': 'Phòng bếp',
        'subtitle': 'Tiện nghi cho gian bếp hiện đại',
        'image': 'assets/rooms/kitchen_banner.jpg',
        'furnitureTypes': [
          {'name': 'Bộ bàn ăn', 'image': 'assets/furniture_types/dining_set.jpg'},
          {'name': 'Tủ bếp', 'image': 'assets/furniture_types/kitchen_cabinet.jpg'},
          {'name': 'Ghế ăn', 'image': 'assets/furniture_types/dining_chair.jpg'},
          {'name': 'Kệ bếp', 'image': 'assets/furniture_types/kitchen_shelf.jpg'},
        ],
      },
      {
        'title': 'Phòng khách',
        'subtitle': 'Không gian thư giãn và tiếp khách',
        'image': 'assets/rooms/living_room_banner.jpg',
        'furnitureTypes': [
          {'name': 'Sofa', 'image': 'assets/furniture_types/sofa.jpg'},
          {'name': 'Bàn trà', 'image': 'assets/furniture_types/coffee_table.jpg'},
          {'name': 'Kệ tivi', 'image': 'assets/furniture_types/tv_stand.jpg'},
          {'name': 'Tủ trang trí', 'image': 'assets/furniture_types/display_cabinet.jpg'},
        ],
      },
      {
        'title': 'Phòng ngủ',
        'subtitle': 'Không gian nghỉ ngơi thư giãn',
        'image': 'assets/rooms/bedroom_banner.jpg',
        'furnitureTypes': [
          {'name': 'Giường ngủ', 'image': 'assets/furniture_types/bed.jpg'},
          {'name': 'Tủ quần áo', 'image': 'assets/furniture_types/wardrobe.jpg'},
          {'name': 'Bàn trang điểm', 'image': 'assets/furniture_types/dresser.jpg'},
          {'name': 'Tab đầu giường', 'image': 'assets/furniture_types/nightstand.jpg'},
        ],
      },
      {
        'title': 'Văn phòng',
        'subtitle': 'Không gian làm việc hiệu quả',
        'image': 'assets/rooms/office_banner.jpg',
        'furnitureTypes': [
          {'name': 'Bàn làm việc', 'image': 'assets/furniture_types/desk.jpg'},
          {'name': 'Ghế văn phòng', 'image': 'assets/furniture_types/office_chair.jpg'},
          {'name': 'Tủ hồ sơ', 'image': 'assets/furniture_types/filing_cabinet.jpg'},
          {'name': 'Kệ sách', 'image': 'assets/furniture_types/bookshelf.jpg'},
        ],
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: allRooms.length,
      itemBuilder: (context, roomIndex) {
        final roomData = allRooms[roomIndex];
        
        return Column(
          children: [
            // Room Banner
            RoomBanner(
              title: roomData['title'] as String,
              subtitle: roomData['subtitle'] as String,
              imagePath: roomData['image'] as String,
              onViewProducts: () {
                // TODO: Navigate to all products in this room
                debugPrint('View all products for ${roomData['title']}');
              },
            ),
            
            // Furniture Types Grid
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
                itemCount: (roomData['furnitureTypes'] as List).length,
                itemBuilder: (context, index) {
                  final furnitureType = (roomData['furnitureTypes'] as List)[index] as Map<String, String>;
                  return FurnitureTypeCard(
                    title: furnitureType['name']!,
                    imagePath: furnitureType['image']!,
                    onTap: () {
                      // TODO: Navigate to products of this furniture type
                      debugPrint('Tapped on ${furnitureType['name']} in ${roomData['title']}');
                    },
                  );
                },
              ),
            ),
            
            // Spacing between rooms
            SizedBox(height: roomIndex < allRooms.length - 1 ? 24 : 80),
          ],
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
