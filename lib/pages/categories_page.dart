import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/category_provider.dart';
import '../components/app_bar_actions.dart';
import '../components/room_category_components.dart';
import '../service/brand_service.dart';
import '../service/api_client.dart';
import '../models/brand_model.dart';
import 'products_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
  with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final BrandService _brandService;
  List<BrandModel> _brands = [];
  bool _isLoadingBrands = false;

  @override
  void initState() {
    super.initState();
    _brandService = BrandService(ApiClient());
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final categoryProvider = context.read<CategoryProvider>();
    await Future.wait([
      categoryProvider.loadCategoryTree(),
      categoryProvider.loadCategories(),
      _loadBrands(),
    ]);
  }

  Future<void> _loadBrands() async {
    setState(() => _isLoadingBrands = true);
    try {
      final result = await _brandService.getAllBrands();
      if (result['success'] == true && mounted) {
        setState(() {
          _brands = result['brands'] ?? [];
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBrands = false);
      }
    }
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
              title: const Text('Phân loại'),
              floating: true,
              snap: true,
              centerTitle: false,
              actions: [
                CommonAppBarActions(),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                tabs: const [
                  Tab(text: 'Theo phòng'),
                  Tab(text: 'Theo danh mục'),
                  Tab(text:' Theo thương hiệu')
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
            _buildBrandsList(),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage(
                          categoryId: category.id,
                        ),
                      ),
                    );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsPage(
                            categoryId: room.id,
                          ),
                        ),
                      );
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsPage(
                                    categoryId: subcategory.id,
                                  ),
                                ),
                              );
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

  Widget _buildBrandsList() {
    if (_isLoadingBrands) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_brands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 80,
              color: AppTheme.char300,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có thương hiệu nào',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.char500,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBrands,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _brands.length,
        itemBuilder: (context, index) {
          final brand = _brands[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsPage(
                      brandId: brand.id,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: brand.image != null && brand.image!.isNotEmpty
                        ? Image.network(
                            brand.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.beige100,
                                child: Icon(
                                  Icons.business,
                                  size: 64,
                                  color: AppTheme.primary500,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppTheme.beige100,
                            child: Icon(
                              Icons.business,
                              size: 64,
                              color: AppTheme.primary500,
                            ),
                          ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            brand.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (brand.description != null && brand.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                brand.description!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.char600,
                                      fontSize: 11,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
