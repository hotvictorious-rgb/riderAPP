import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/rider_delivery_provider.dart';

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
      appBar: AppBar(title: const Text('COMPLETED TRIPS')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deliv.history.length,
        itemBuilder: (context, idx) {
          final item = deliv.history[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.obsidianCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.obsidianBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.orderNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 3),
                    Text(item.customerName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text(item.timestamp, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(item.deliveryCharge),
                      style: const TextStyle(color: AppColors.dispatchEmerald, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    const Text('Delivered', style: TextStyle(color: AppColors.dispatchEmerald, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}