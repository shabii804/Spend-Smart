import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../providers/language_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final current = langProvider.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: LanguageProvider.options.map((o) {
            final sel = current.id == o.id;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  langProvider.setLanguage(o.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${o.name} (${o.nativeName})'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: sel
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryIndigo.withOpacity(0.12),
                              AppColorsOf.card(context),
                            ],
                          )
                        : null,
                    color: sel ? null : AppColorsOf.card(context),
                    border: Border.all(
                      color: sel ? AppColors.primaryIndigo : AppColorsOf.border(context),
                      width: sel ? 1.6 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(o.flag, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.name,
                                style: TextStyles.body(context, weight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(o.nativeName,
                                style: TextStyles.caption(context).copyWith(
                                  color: AppColorsOf.secondaryText(context),
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: sel ? AppColors.primaryIndigo : AppColorsOf.border(context),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: sel
                            ? Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryIndigo,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
