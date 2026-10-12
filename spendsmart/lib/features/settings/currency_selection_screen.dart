import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/currency_provider.dart';

class CurrencySelectionScreen extends StatelessWidget {
  const CurrencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cur = context.watch<CurrencyProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.currencySelection),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: CurrencyProvider.options
              .map((o) {
                final sel = cur.id == o.id;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => cur.setCurrency(o.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        // Subtle gradient background when selected — matches Theme Settings
                        gradient: sel
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryIndigo.withOpacity(0.10),
                                  AppColorsOf.card(context),
                                ],
                              )
                            : null,
                        color: sel ? null : AppColorsOf.card(context),
                        border: Border.all(
                          color: sel
                              ? AppColors.primaryIndigo
                              : AppColorsOf.border(context),
                          width: sel ? 1.6 : 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: sel
                                    ? [
                                        AppColors.primaryIndigo.withOpacity(0.24),
                                        AppColors.primaryPurple.withOpacity(0.14),
                                      ]
                                    : [
                                        AppColorsOf.tertiaryText(context).withOpacity(0.16),
                                        AppColorsOf.tertiaryText(context).withOpacity(0.08),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              o.symbol,
                              style: TextStyles.body(context, weight: FontWeight.w700)
                                  .copyWith(
                                    color: sel
                                        ? AppColors.primaryIndigo
                                        : AppColorsOf.secondaryText(context),
                                    fontSize: 18,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.name,
                                    style: TextStyles.body(context,
                                        weight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('${o.id} · ${o.symbol}',
                                    style: TextStyles.caption(context)),
                              ],
                            ),
                          ),
                          // Animated check circle — same style as Theme Settings
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: sel
                                    ? AppColors.primaryIndigo
                                    : AppColorsOf.border(context),
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
              })
              .toList(),
        ),
      ),
    );
  }
}
