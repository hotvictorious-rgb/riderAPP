import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/delivery_assignment_model.dart';
import '../models/order_item_manifest_model.dart';
import 'live_camera_proof_card.dart';

class DoorstepHandoverManifestDialog extends StatefulWidget {
  final DeliveryAssignmentModel assignment;
  final Future<Map<String, dynamic>> Function(
    String otp,
    List<Map<String, dynamic>> manifestItems,
    File? overallPhoto,
    Map<int, File> itemDefectPhotos,
  ) onSubmit;

  const DoorstepHandoverManifestDialog({
    super.key,
    required this.assignment,
    required this.onSubmit,
  });

  @override
  State<DoorstepHandoverManifestDialog> createState() => _DoorstepHandoverManifestDialogState();
}

class _DoorstepHandoverManifestDialogState extends State<DoorstepHandoverManifestDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _isItemizedMode = false;
  bool _isSubmitting = false;
  String? _error;
  File? _overallPhoto;
  final Map<int, File> _itemDefectPhotos = {};
  late List<OrderItemManifestModel> _manifest;

  @override
  void initState() {
    super.initState();
    if (widget.assignment.manifestItems.isNotEmpty) {
      _manifest = widget.assignment.manifestItems
          .map((m) => OrderItemManifestModel(
                orderItemId: m.orderItemId,
                productName: m.productName,
                orderedQuantity: m.orderedQuantity,
                acceptedQuantity: m.orderedQuantity,
                rejectedQuantity: 0,
              ))
          .toList();
    } else {
      _manifest = [
        OrderItemManifestModel(
          orderItemId: widget.assignment.id,
          productName: widget.assignment.itemsSummary,
          orderedQuantity: widget.assignment.itemsCount,
          acceptedQuantity: widget.assignment.itemsCount,
          rejectedQuantity: 0,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  bool get _hasRejections => _manifest.any((i) => i.rejectedQuantity > 0);

  Future<void> _handleConfirm() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Please enter the full 6-digit Customer Security PIN.');
      return;
    }

    if (_hasRejections) {
      for (final item in _manifest) {
        if (item.rejectedQuantity > 0 && item.rejectionCategory == null) {
          setState(() => _error = 'Please select a return reason for "".');
          return;
        }
      }
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final manifestPayload = _manifest.map((i) => i.toManifestJson()).toList();
    final result = await widget.onSubmit(otp, manifestPayload, _overallPhoto, _itemDefectPhotos);

    if (mounted) {
      if (result['success'] == true) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isSubmitting = false;
          _error = result['message'] as String? ?? 'Handover certification failed.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.obsidianCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dispatchEmerald.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user, size: 13, color: AppColors.dispatchEmerald),
                        SizedBox(width: 4),
                        Text('DOORSTEP PROTOCOL', style: TextStyle(color: AppColors.dispatchEmerald, fontSize: 10, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Text(
                    widget.assignment.orderNumber,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Handover: ',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text(
                widget.assignment.deliveryAddress,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 16),

              // Mode Selector (Full vs Partial Acceptance)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.obsidianBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isItemizedMode = false;
                            for (var i in _manifest) {
                              i.acceptedQuantity = i.orderedQuantity;
                              i.rejectedQuantity = 0;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isItemizedMode ? AppColors.dispatchEmerald.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: !_isItemizedMode ? Border.all(color: AppColors.dispatchEmerald.withOpacity(0.5)) : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Full Delivery (All Items)',
                            style: TextStyle(
                              color: !_isItemizedMode ? AppColors.dispatchEmerald : AppColors.textMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isItemizedMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isItemizedMode ? AppColors.urgentRed.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _isItemizedMode ? Border.all(color: AppColors.urgentRed.withOpacity(0.5)) : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Partial / Defect Found',
                            style: TextStyle(
                              color: _isItemizedMode ? AppColors.urgentRed : AppColors.textMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Itemized Manifest Section
              if (_isItemizedMode) ...[
                const Text(
                  'DOORSTEP ITEM VERIFICATION',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                ..._manifest.map((item) => _buildManifestItemCard(item)),
                const SizedBox(height: 12),
              ],

              // Overall Doorstep Proof
              LiveCameraProofCard(
                photo: _overallPhoto,
                onPhotoChanged: (f) => setState(() => _overallPhoto = f),
                title: 'Doorstep Handover Overall Proof',
                hint: 'Snap live picture of parcel handover at doorstep.',
              ),
              const SizedBox(height: 16),

              // Customer Security OTP Input
              const Text('CUSTOMER 6-DIGIT DELIVERY PIN', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.richGold, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 6),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 6),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.obsidianBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2)),
                ),
              ),

              if (_hasRejections) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.urgentRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.urgentRed.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.assignment_return, color: AppColors.urgentRed, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rejected items will be credited back to customer wallet & scheduled for merchant return.',
                          style: TextStyle(color: AppColors.urgentRed, fontSize: 10.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.urgentRed, fontSize: 11, fontWeight: FontWeight.w600)),
              ],

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasRejections ? AppColors.urgentRed : AppColors.dispatchEmerald,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _hasRejections ? 'Certify Partial Handover' : 'Confirm Full Delivery',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManifestItemCard(OrderItemManifestModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.rejectedQuantity > 0 ? AppColors.urgentRed.withOpacity(0.4) : AppColors.obsidianBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ),
              Text(
                'Total: ',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accepted: ',
                style: const TextStyle(color: AppColors.dispatchEmerald, fontSize: 11, fontWeight: FontWeight.w800),
              ),
              Row(
                children: [
                  const Text('Rejected: ', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.urgentRed, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: item.rejectedQuantity > 0
                        ? () {
                            setState(() {
                              item.rejectedQuantity--;
                              item.acceptedQuantity++;
                              if (item.rejectedQuantity == 0) {
                                item.rejectionCategory = null;
                                _itemDefectPhotos.remove(item.orderItemId);
                              }
                            });
                          }
                        : null,
                  ),
                  Text(
                    '',
                    style: TextStyle(
                      color: item.rejectedQuantity > 0 ? AppColors.urgentRed : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.urgentRed, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: item.acceptedQuantity > 0
                        ? () {
                            setState(() {
                              item.rejectedQuantity++;
                              item.acceptedQuantity--;
                              item.rejectionCategory ??= 'vendor_issue';
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
          if (item.rejectedQuantity > 0) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: item.rejectionCategory,
              decoration: InputDecoration(
                labelText: 'Rejection Reason',
                labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                isDense: true,
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              dropdownColor: AppColors.obsidianCard,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              items: const [
                DropdownMenuItem(value: 'vendor_issue', child: Text('Vendor Issue (Wrong/Defective Item)')),
                DropdownMenuItem(value: 'transit_damage', child: Text('Transit Damage (Courier Incident)')),
                DropdownMenuItem(value: 'customer_change_of_mind', child: Text('Customer Doorstep Change of Mind')),
              ],
              onChanged: (val) => setState(() => item.rejectionCategory = val),
            ),
            const SizedBox(height: 8),
            LiveCameraProofCard(
              photo: _itemDefectPhotos[item.orderItemId],
              onPhotoChanged: (f) => setState(() {
                if (f != null) {
                  _itemDefectPhotos[item.orderItemId] = f;
                } else {
                  _itemDefectPhotos.remove(item.orderItemId);
                }
              }),
              title: 'Live Defect Photo: ',
              hint: 'Snap live picture of damaged item/broken seal.',
              isRequired: false,
            ),
          ],
        ],
      ),
    );
  }
}
