import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/promotion_model.dart';
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
              title: const Text('Khuyến mãi & Hướng dẫn'),
              floating: true,
              snap: true,
              actions: const [
                CommonAppBarActions(showWishlist: false),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.local_offer),
                    text: 'Khuyến mãi',
                  ),
                  Tab(
                    icon: Icon(Icons.help_outline),
                    text: 'Hướng dẫn',
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
            _buildGuideList(),
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

  Widget _buildPromotionCard(PromotionModel promotion) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showPromotionDetails(promotion);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Discount badge
                Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary400, AppTheme.primary600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          promotion.discountText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'OFF',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title and status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              promotion.code,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: promotion.isValid
                                  ? AppTheme.success
                                  : AppTheme.char300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              promotion.statusText,
                              style: TextStyle(
                                color: promotion.isValid
                                    ? Colors.white
                                    : AppTheme.char600,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        promotion.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Min spend
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 12,
                            color: AppTheme.char500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              promotion.minSpendText,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.char500,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Days remaining
                      if (promotion.daysRemaining > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: AppTheme.char500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Còn ${promotion.daysRemaining} ngày',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.char500,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.char400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideList() {
    final guideSteps = [
      {
        'step': '1',
        'title': 'Sao chép mã giảm giá bạn muốn sử dụng',
      },
      {
        'step': '2',
        'title': 'Thêm sản phẩm vào giỏ hàng và tiến hành thanh toán',
      },
      {
        'step': '3',
        'title': 'Nhập mã giảm giá vào ô "Mã khuyến mãi" tại trang thanh toán',
      },
      {
        'step': '4',
        'title': 'Nhấn "Áp dụng" để được giảm giá',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hướng dẫn sử dụng mã giảm giá',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          ...guideSteps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primary100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary400,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          step['step'] as String,
                          style: TextStyle(
                            color: AppTheme.primary600,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          step['title'] as String,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.info,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lưu ý: Mỗi đơn hàng chỉ được sử dụng một mã giảm giá. Kiểm tra điều kiện áp dụng của từng mã trước khi sử dụng.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.char700,
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  void _showPromotionDetails(PromotionModel promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary400, AppTheme.primary600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          promotion.discountText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'GIẢM GIÁ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    promotion.description,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.code, 'Mã khuyến mãi', promotion.code),
                  _buildDetailRow(Icons.calendar_today, 'Hạn sử dụng', promotion.dateRangeText),
                  _buildDetailRow(
                    Icons.shopping_cart,
                    'Đơn tối thiểu',
                    promotion.minSpend > 0
                        ? '${promotion.minSpend.toStringAsFixed(0)}đ'
                        : 'Không giới hạn',
                  ),
                  _buildDetailRow(
                    Icons.discount,
                    'Loại giảm giá',
                    promotion.discountType == DiscountType.percentage
                        ? 'Phần trăm'
                        : 'Số tiền cố định',
                  ),
                  _buildDetailRow(
                    Icons.check_circle,
                    'Trạng thái',
                    promotion.statusText,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Điều kiện áp dụng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildConditionItem('Áp dụng cho tất cả sản phẩm'),
                  _buildConditionItem(
                    promotion.minSpend > 0
                        ? 'Đơn hàng tối thiểu ${promotion.minSpend.toStringAsFixed(0)}đ'
                        : 'Không giới hạn giá trị đơn hàng',
                  ),
                  _buildConditionItem('Không áp dụng cùng mã khác'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: promotion.isValid
                        ? () {
                            Navigator.pop(context);
                            // TODO: Copy code to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã sao chép mã ${promotion.code}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      promotion.isValid ? 'Sao chép mã' : 'Mã không còn hiệu lực',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

  Widget _buildConditionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
