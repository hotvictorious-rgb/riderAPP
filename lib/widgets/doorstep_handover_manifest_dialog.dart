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
  bool _isLocked = false;
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
    if (_isLocked) return;
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Please enter the full 6-digit Customer Security PIN.');
      return;
    }
    if (_overallPhoto == null) {
      setState(() => _error = 'Mandatory: Live photo of package condition at doorstep is required.');
      return;
    }
    if (_hasRejections) {
      for (final item in _manifest) {
        if (item.rejectedQuantity > 0 && _itemDefectPhotos[item.orderItemId] == null) {
          setState(() => _error = 'Mandatory: Please snap a live defect photo for rejected item "${item.productName}".');
          return;
        }
      }
    }

    if (_hasRejections) {
      for (final item in _manifest) {
        if (item.rejectedQuantity > 0 && item.rejectionCategory == null) {
          setState(() => _error = 'Please select a return reason for "${item.productName}".');
          return;
        }
      }
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final manifestPayload = _manifest
        .map((i) => {
              'order_item_id': i.orderItemId,
              'accepted_quantity': i.acceptedQuantity,
              'rejected_quantity': i.rejectedQuantity,
              'rejection_category': i.rejectionCategory,
              'rejection_notes': i.rejectionNotes,
            })
        .toList();

    try {
      final res = await widget.onSubmit(otp, manifestPayload, _overallPhoto, _itemDefectPhotos);
      if (mounted) {
        if (res['success'] == true) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _isSubmitting = false;
            _error = res['message'] as String? ?? 'Handover verification failed.';
            _isLocked = res['is_locked'] == true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = 'Communication failure: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
                      color: AppColors.dispatchEmerald.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.3), width: 1.0),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user, size: 12, color: AppColors.dispatchEmerald),
                        SizedBox(width: 5),
                        Text('DOORSTEP PROTOCOL', style: TextStyle(color: AppColors.dispatchEmerald, fontSize: 9.5, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                    ),
                    child: Text(
                      widget.assignment.orderNumber,
                      style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Handover: ${widget.assignment.customerName}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                widget.assignment.deliveryAddress,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 16),

              // Mode Selector (Full vs Partial Acceptance)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                ),
                padding: const EdgeInsets.all(4),
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
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: !_isItemizedMode ? AppColors.dispatchEmerald.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: !_isItemizedMode ? Border.all(color: AppColors.dispatchEmerald.withOpacity(0.4), width: 1.0) : null,
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
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isItemizedMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _isItemizedMode ? AppColors.urgentRed.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: _isItemizedMode ? Border.all(color: AppColors.urgentRed.withOpacity(0.4), width: 1.0) : null,
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
                isRequired: true,
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
                style: const TextStyle(color: AppColors.primaryGold, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 8),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 8),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1.0)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1.0)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5)),
                ),
              ),

              if (_hasRejections) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.urgentRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.urgentRed.withOpacity(0.3), width: 1.0),
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

              if (_isLocked) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.urgentRed.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.urgentRed, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, color: AppColors.urgentRed, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'SECURITY LOCKOUT: Maximum PIN attempts exceeded. Contact Fleet Operations & Dispatch immediately.',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_error != null && !_isLocked) ...[
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
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting || _isLocked) ? null : _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasRejections ? AppColors.urgentRed : AppColors.dispatchEmerald,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                _hasRejections ? 'Certify Partial Handover' : 'Confirm Full Delivery',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                              ),
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
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.rejectedQuantity > 0 ? AppColors.urgentRed.withOpacity(0.4) : AppColors.surfaceBorder,
          width: 1.0,
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
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Total: ${item.orderedQuantity}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accepted: ${item.acceptedQuantity}',
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
                    '${item.rejectedQuantity}',
                    style: TextStyle(
                      color: item.rejectedQuantity > 0 ? AppColors.urgentRed : AppColors.textPrimary,
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
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1.0)),
              ),
              dropdownColor: AppColors.surfaceElevated,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
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
              title: 'Live Defect Photo: ${item.productName}',
              hint: 'Snap live picture of damaged item/broken seal.',
              isRequired: false,
            ),
          ],
        ],
      ),
    );
  }
}
