import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();
    final items = prov.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (prov.unreadCount > 0)
            TextButton.icon(
              onPressed: prov.markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: Text(AppStrings.markAllRead,
                  style: TextStyles.caption(context, weight: FontWeight.w700)),
            ),
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: AppStrings.noNotifications,
                subtitle: AppStrings.noNotificationsSubtitle,
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final n = items[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => prov.markRead(n.id),
                      child: GlassCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        customColor: n.isRead ? null : n.color.withOpacity(0.06),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: n.color.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Icon(n.icon, color: n.color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(n.title,
                                            style: TextStyles.body(context,
                                                weight: FontWeight.w700)),
                                      ),
                                      Text(n.timeAgo,
                                          style: TextStyles.caption(context)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(n.body,
                                      style: TextStyles.caption(context)),
                                ],
                              ),
                            ),
                            if (!n.isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryIndigo,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
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
