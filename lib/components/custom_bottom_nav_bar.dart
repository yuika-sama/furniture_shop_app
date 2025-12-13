import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Custom bottom navigation bar
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primary500,
      unselectedItemColor: AppTheme.char500,
      selectedLabelStyle: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: 'Danh mục',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer_outlined),
          activeIcon: Icon(Icons.local_offer),
          label: 'Khuyến mãi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}
