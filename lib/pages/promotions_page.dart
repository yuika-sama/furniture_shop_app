import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/promotion_provider.dart';
import '../components/app_bar_actions.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPromotions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPromotions() async {
    final promotionProvider = context.read<PromotionProvider>();
    await promotionProvider.loadPromotions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Khuyến mãi & Thông báo'),
              floating: true,
              snap: true,
              actions: const [
                CommonAppBarActions(showWishlist: false),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.local_offer),
                    text: 'Khuyến mãi',
                  ),
                  Tab(
                    icon: Icon(Icons.notifications),
                    text: 'Thông báo',
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPromotionsList(),
            _buildNotificationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionsList() {
    return Consumer<PromotionProvider>(
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
                  onPressed: _loadPromotions,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (provider.promotions.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadPromotions,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.promotions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final promotion = provider.promotions[index];
              return _buildPromotionCard(promotion);
            },
          ),
        );
      },
    );
  }

  Widget _buildPromotionCard(dynamic promotion) {
    // Mock promotion card - will be replaced with actual data
    return Card(
      child: InkWell(
        onTap: () {
          _showPromotionDetails(promotion);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.warning, AppTheme.warning.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '20%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giảm giá 20% cho đơn từ 5 triệu',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.beige100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'SUMMER2025',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.primary500,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.char500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'HSD: 31/12/2025',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.char500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.char400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final notifications = [
      {
        'title': 'Đơn hàng đã được giao',
        'message': 'Đơn hàng #DH001 đã được giao thành công',
        'time': '2 giờ trước',
        'icon': Icons.check_circle,
        'color': AppTheme.success,
        'read': false,
      },
      {
        'title': 'Khuyến mãi mới',
        'message': 'Giảm giá 30% cho bộ sưu tập mùa hè',
        'time': '1 ngày trước',
        'icon': Icons.local_offer,
        'color': AppTheme.warning,
        'read': false,
      },
      {
        'title': 'Đơn hàng đang giao',
        'message': 'Đơn hàng #DH002 đang trên đường giao đến bạn',
        'time': '2 ngày trước',
        'icon': Icons.local_shipping,
        'color': AppTheme.info,
        'read': true,
      },
      {
        'title': 'Sản phẩm yêu thích đang giảm giá',
        'message': 'Ghế sofa bạn đã thích đang giảm giá 25%',
        'time': '3 ngày trước',
        'icon': Icons.favorite,
        'color': AppTheme.error,
        'read': true,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final isRead = notification['read'] as bool;

        return Container(
          color: isRead ? Colors.transparent : AppTheme.primary50,
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (notification['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification['icon'] as IconData,
                color: notification['color'] as Color,
              ),
            ),
            title: Text(
              notification['title'] as String,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification['message'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notification['time'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.char500,
                      ),
                ),
              ],
            ),
            trailing: !isRead
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary500,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
            onTap: () {
              // TODO: Mark as read and show details
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 80,
            color: AppTheme.char300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có khuyến mãi nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.char500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các chương trình khuyến mãi sẽ được\ncập nhật thường xuyên',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.char400,
                ),
          ),
        ],
      ),
    );
  }

  void _showPromotionDetails(dynamic promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.char300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.warning, AppTheme.warning.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '20%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'GIẢM GIÁ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Giảm giá 20% cho đơn từ 5 triệu',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.code, 'Mã khuyến mãi', 'SUMMER2025'),
                  _buildDetailRow(Icons.calendar_today, 'Hạn sử dụng', '31/12/2025'),
                  _buildDetailRow(Icons.shopping_cart, 'Đơn tối thiểu', '5.000.000đ'),
                  _buildDetailRow(Icons.confirmation_number, 'Số lượng', 'Không giới hạn'),
                  const SizedBox(height: 24),
                  Text(
                    'Điều kiện áp dụng:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Áp dụng cho tất cả sản phẩm\n'
                    '• Giá trị đơn hàng tối thiểu 5.000.000đ\n'
                    '• Không áp dụng cùng khuyến mãi khác\n'
                    '• Có hiệu lực đến 31/12/2025',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Copy code
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Sao chép mã'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: Apply promotion
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.char600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
