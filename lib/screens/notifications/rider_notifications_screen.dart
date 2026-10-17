import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/system_notification_model.dart';
import '../../providers/rider_notification_provider.dart';

class RiderNotificationsScreen extends StatefulWidget {
  const RiderNotificationsScreen({super.key});

  @override
  State<RiderNotificationsScreen> createState() => _RiderNotificationsScreenState();
}

class _RiderNotificationsScreenState extends State<RiderNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RiderNotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<RiderNotificationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      appBar: AppBar(
        title: const Text('DISPATCH ALERTS'),
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notifProvider.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 16, color: AppColors.cyberGold),
              label: const Text(
                'Mark All Read',
                style: TextStyle(
                  color: AppColors.cyberGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.cyberGold,
        backgroundColor: AppColors.carbonSurface,
        onRefresh: () => notifProvider.fetchNotifications(),
        child: _buildBody(notifProvider),
      ),
    );
  }

  Widget _buildBody(RiderNotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cyberGold),
      );
    }

    if (provider.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.cyberGold.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.pad(
                      EdgeInsets.all(1),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 36,
                    color: AppColors.cyberGold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'All Caught Up',
                  style: TextStyle(
                    color: AppColors.frostWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'No unread dispatch orders, pickup assignments, or payout alerts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.slateMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: provider.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notif = provider.notifications[index];
        return _buildNotificationCard(notif, provider);
      },
    );
  }

  Widget _buildNotificationCard(SystemNotificationModel notif, RiderNotificationProvider provider) {
    final isUnread = !notif.isRead;

    return InkWell(
      onTap: () {
        if (isUnread) {
          provider.markAsRead(notif.id);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.carbonSurface
              : AppColors.carbonSurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread
                ? notif.accentColor.withOpacity(0.35)
                : AppColors.steelBorder.withOpacity(0.4),
            width: isUnread ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notif.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: notif.accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                notif.iconData,
                color: notif.accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            color: isUnread ? AppColors.frostWhite : AppColors.frostWhite.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.cyberGold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyberGold,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      color: AppColors.slateMuted,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notif.timeAgo,
                        style: TextStyle(
                          color: AppColors.slateMuted.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      if (notif.actionUrl != null && notif.actionUrl!.isNotEmpty)
                        Text(
                          'View Mission ›',
                          style: TextStyle(
                            color: notif.accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
