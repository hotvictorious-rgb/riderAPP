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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('REVERSE LOGISTICS DROPOFF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => deliv.fetchActiveReturns(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: AppColors.surface,
        onRefresh: () => deliv.fetchActiveReturns(),
        child: deliv.isLoading && deliv.activeReturns.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : deliv.activeReturns.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.dispatchEmerald.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.25), width: 1.0),
                                ),
                                child: const Icon(Icons.check_circle_outline, size: 28, color: AppColors.dispatchEmerald),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No Pending Return Dropoffs',
                                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16),
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
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.35), width: 1.0),
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
                  color: AppColors.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.25), width: 1.0),
                ),
                child: Text(
                  item.caseNumber,
                  style: const TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.urgentRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.urgentRed.withOpacity(0.25), width: 1.0),
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
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            item.itemsSummary,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: 12),

          // Vendor Dropoff Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.25), width: 1.0),
                ),
                child: const Icon(Icons.store, color: AppColors.primaryGold, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RETURN TO: ${item.shopName}',
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
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
                        style: const TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.w800),
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
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.urgentRed.withOpacity(0.3), width: 1.0),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.doorstepPhotoPath!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: AppColors.surfaceElevated,
                              child: const Icon(Icons.broken_image, size: 20, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Doorstep Defect Evidence', style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w800)),
                              SizedBox(height: 2),
                              Text('Tap to inspect full audit photo before handover.', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                            ],
                          ),
                        ),
                        const Icon(Icons.fullscreen, color: AppColors.primaryGold, size: 18),
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
            height: 46,
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
                        content: Text('✓ Return Handover Certified! Parcel returned to vendor shop.'),
                      ),
                    );
                  }
                });
              },
              icon: const Icon(Icons.verified, size: 16),
              label: const Text('Handover Parcel at Shop & Enter Vendor PIN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
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
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Unable to load photo', style: TextStyle(color: AppColors.textMuted))),
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
