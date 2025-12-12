import 'package:flutter/material.dart';

/// Test API Page - Hub để test tất cả các API với UI đẹp
class TestApiPage extends StatelessWidget {
  const TestApiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('🧪 API Test Hub'),
            expandedHeight: 180,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade400,
                      Colors.purple.shade400,
                    ],
                  ),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.api, size: 48, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'Test tất cả API endpoints',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildListDelegate([
                _buildApiCard(
                  context,
                  title: 'Auth',
                  icon: Icons.login,
                  color: Colors.blue,
                  route: '/test/auth',
                ),
                _buildApiCard(
                  context,
                  title: 'Products',
                  icon: Icons.inventory_2,
                  color: Colors.green,
                  route: '/test/product',
                ),
                _buildApiCard(
                  context,
                  title: 'Categories',
                  icon: Icons.category,
                  color: Colors.orange,
                  route: '/test/category',
                ),
                _buildApiCard(
                  context,
                  title: 'Brands',
                  icon: Icons.branding_watermark,
                  color: Colors.purple,
                  route: '/test/brand',
                ),
                _buildApiCard(
                  context,
                  title: 'Cart',
                  icon: Icons.shopping_cart,
                  color: Colors.red,
                  route: '/test/cart',
                ),
                _buildApiCard(
                  context,
                  title: 'Orders',
                  icon: Icons.receipt_long,
                  color: Colors.teal,
                  route: '/test/order',
                ),
                _buildApiCard(
                  context,
                  title: 'Reviews',
                  icon: Icons.star,
                  color: Colors.amber,
                  route: '/test/review',
                ),
                _buildApiCard(
                  context,
                  title: 'Wishlist',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  route: '/test/wishlist',
                ),
                _buildApiCard(
                  context,
                  title: 'Promotions',
                  icon: Icons.local_offer,
                  color: Colors.deepOrange,
                  route: '/test/promotion',
                ),
                _buildApiCard(
                  context,
                  title: 'User',
                  icon: Icons.person,
                  color: Colors.indigo,
                  route: '/test/user',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
