import 'package:flutter/material.dart';
import 'package:acumen/features/resources/utils/resource_utils.dart';
import 'package:acumen/theme/app_theme.dart';

class ResourceFilterWidget extends StatelessWidget {
  final String? selectedType;
  final Function(String?) onTypeSelected;

  const ResourceFilterWidget({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ResourceUtils.getResourceTypes().map((type) {
            final isSelected = selectedType == type || 
                (type == 'All' && selectedType == null);
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  onTypeSelected(selected ? 
                      (type == 'All' ? null : type) : null);
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
} 