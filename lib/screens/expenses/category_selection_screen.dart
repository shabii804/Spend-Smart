import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../data/sample_data.dart';

/// Modal-style category picker. Returns the chosen category id via pop().
class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.selectCategoryTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemCount: SampleData.categories.length,
          itemBuilder: (_, i) {
            final c = SampleData.categories[i];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop(c.id);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColorsOf.card(context),
                    border: Border.all(color: AppColorsOf.border(context)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: c.color.withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(c.icon, color: c.color, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(c.name, style: TextStyles.body(context,
                          weight: FontWeight.w600),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
