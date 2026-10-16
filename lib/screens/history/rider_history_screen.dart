import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_delivery_provider.dart';
import '../deliveries/delivery_detail_screen.dart';

class RiderHistoryScreen extends StatefulWidget {
  const RiderHistoryScreen({super.key});

  @override
  State<RiderHistoryScreen> createState() => _RiderHistoryScreenState();
}

class _RiderHistoryScreenState extends State<RiderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RiderDeliveryProvider>(context, listen: false).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliv = Provider.of<RiderDeliveryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      appBar: AppBar(
        title: const Text('DISPATCH TRIP LOG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Trip Log',
            onPressed: () => deliv.fetchHistory(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => deliv.fetchHistory(),
        child: deliv.isLoading && deliv.history.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.dispatchEmerald))
            : deliv.history.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 14),
                            Text(
                              'No completed deliveries yet for this shift.',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pull down or tap refresh to sync with dispatch server.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: deliv.history.length,
                    itemBuilder: (context, idx) {
                      final item = deliv.history[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.obsidianCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.obsidianBorder),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DeliveryDetailScreen(assignment: item),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              item.orderNumber,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.06),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.dispatchCategory,
                                                style: const TextStyle(color: AppColors.richGold, fontSize: 9, fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Recipient: ${item.customerName}',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.destinationLga} • ${item.timestamp}',
                                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.dispatchEmerald.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.3)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle, size: 12, color: AppColors.dispatchEmerald),
                                            SizedBox(width: 4),
                                            Text(
                                              'VERIFIED',
                                              style: TextStyle(
                                                color: AppColors.dispatchEmerald,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'OTP Handover',
                                        style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                                ],
                              ),
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