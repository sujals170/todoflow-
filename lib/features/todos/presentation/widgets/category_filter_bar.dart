import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('work')) return Icons.work_outline_rounded;
    if (lower.contains('personal')) return Icons.person_outline_rounded;
    if (lower.contains('shop')) return Icons.shopping_bag_outlined;
    if (lower.contains('urgent') || lower.contains('fire')) return Icons.local_fire_department_rounded;
    if (lower.contains('health') || lower.contains('fit')) return Icons.favorite_border_rounded;
    if (lower.contains('study') || lower.contains('learn')) return Icons.school_outlined;
    return Icons.tag_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Standard Stitch category presets + user categories
    final Set<String> allCats = {
      'Work',
      'Personal',
      'Shopping',
      'Urgent',
      ...categories,
    };

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // #All Chip
          _buildChip(
            label: '#All',
            icon: Icons.grid_view_rounded,
            isSelected: selectedCategory == null,
            isDark: isDark,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 8),
          ...allCats.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: '#$cat',
                icon: _getCategoryIcon(cat),
                isSelected: selectedCategory == cat,
                isDark: isDark,
                onTap: () => onCategorySelected(selectedCategory == cat ? null : cat),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : AppColors.lightContainerLow),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
