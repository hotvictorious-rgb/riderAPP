import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/return_case_model.dart';
import '../../providers/rider_delivery_provider.dart';
import '../../widgets/vendor_return_otp_dialog.dart';

class RiderReturnsScreen extends StatefulWidget {
  const RiderReturnsScreen({super.key});

  @override
  State<RiderReturnsScreen> createState() => _RiderReturnsScreenState();
}

class _RiderReturnsScreenState extends State<RiderReturnsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RiderDeliveryProvider>(context, listen: false).fetchActiveReturns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliv = Provider.of<RiderDeliveryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      appBar: AppBar(
        title: const Text('REVERSE LOGISTICS DROPOFF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => deliv.fetchActiveReturns(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => deliv.fetchActiveReturns(),
        child: deliv.isLoading && deliv.activeReturns.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.richGold))
            : deliv.activeReturns.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.dispatchEmerald.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_outline, size: 36, color: AppColors.dispatchEmerald),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Pending Return Dropoffs',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'You have zero customer-rejected parcels in your courier custody. All returns are cleared.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: deliv.activeReturns.length,
                    itemBuilder: (context, idx) {
                      final item = deliv.activeReturns[idx];
                      return _buildReturnCaseCard(context, item, deliv);
                    },
                  ),
      ),
    );
  }

  Widget _buildReturnCaseCard(BuildContext context, ReturnCaseModel item, RiderDeliveryProvider deliv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.richGold.withOpacity(0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Case number & Rejection Reason Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.richGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.richGold.withOpacity(0.3)),
                ),
                child: Text(
                  item.caseNumber,
                  style: const TextStyle(color: AppColors.richGold, fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.urgentRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.rejectionCategoryLabel,
                  style: const TextStyle(color: AppColors.urgentRed, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order Link & Items
          Text(
            item.orderNumber,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            item.itemsSummary,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.obsidianBorder),
          const SizedBox(height: 8),

          // Vendor Dropoff Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.store, color: AppColors.richGold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RETURN TO: ${item.shopName}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.shopAddress,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    if (item.shopPhone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Shop Contact: ${item.shopPhone}',
                        style: const TextStyle(color: AppColors.richGold, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (item.doorstepPhotoPath != null && item.doorstepPhotoPath!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.urgentRed.withOpacity(0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _openImageDialog(
                    context,
                    item.doorstepPhotoPath!,
                    'Return Defect Evidence • ${item.caseNumber}',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            item.doorstepPhotoPath!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: Colors.white10,
                              child: const Icon(Icons.broken_image, size: 20, color: Colors.white38),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Doorstep Defect Evidence', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                              SizedBox(height: 2),
                              Text('Tap to inspect full audit photo before handover.', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                            ],
                          ),
                        ),
                        const Icon(Icons.fullscreen, color: AppColors.richGold, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Action Button to Open Vendor Return OTP Dialog
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => VendorReturnOtpDialog(
                    returnCase: item,
                    onVerify: (otp, livePhoto) => deliv.verifyVendorReturnOtp(returnCaseId: item.id, otp: otp, livePhoto: livePhoto),
                  ),
                ).then((success) {
                  if (success == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.dispatchEmerald,
                        content: const Text('✓ Return Handover Certified! Parcel returned to vendor shop.'),
                      ),
                    );
                  }
                });
              },
              icon: const Icon(Icons.verified, size: 16),
              label: const Text('Handover Parcel at Shop & Enter Vendor PIN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.richGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openImageDialog(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.obsidianCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.urgentRed.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Unable to load photo', style: TextStyle(color: Colors.white54))),
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

