import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Category card component with image background and title overlay
class CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap,
    this.width = 180,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image not found
                  return Container(
                    color: AppTheme.beige100,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: AppTheme.char400,
                      ),
                    ),
                  );
                },
              ),
              // Gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrollable list of category cards
class CategoryCardList extends StatelessWidget {
  final List<Map<String, String>> categories;
  final Function(int)? onCategoryTap;
  final double cardWidth;
  final double cardHeight;

  const CategoryCardList({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.cardWidth = 180,
    this.cardHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            title: category['name'] ?? '',
            imagePath: category['image'] ?? '',
            width: cardWidth,
            height: cardHeight,
            onTap: onCategoryTap != null ? () => onCategoryTap!(index) : null,
          );
        },
      ),
    );
  }
}
