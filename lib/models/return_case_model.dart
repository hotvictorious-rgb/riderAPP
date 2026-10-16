class ReturnCaseModel {
  final int id;
  final String caseNumber;
  final int orderId;
  final String orderNumber;
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String customerName;
  final String customerPhone;
  final String rejectionCategory;
  final String status; // 'in_transit_back_to_vendor', 'returned_to_vendor'
  final String? doorstepPhotoPath;
  final String totalRefundableAmount;
  final String itemsSummary;
  final String timestamp;

  ReturnCaseModel({
    required this.id,
    required this.caseNumber,
    required this.orderId,
    required this.orderNumber,
    required this.shopName,
    required this.shopAddress,
    required this.shopPhone,
    required this.customerName,
    required this.customerPhone,
    required this.rejectionCategory,
    required this.status,
    this.doorstepPhotoPath,
    required this.totalRefundableAmount,
    required this.itemsSummary,
    required this.timestamp,
  });

  String get rejectionCategoryLabel {
    switch (rejectionCategory) {
      case 'vendor_issue':
        return 'Vendor Issue (Defect / Wrong Item)';
      case 'transit_damage':
        return 'Transit Damage';
      case 'customer_change_of_mind':
        return 'Customer Doorstep Return';
      default:
        return 'Doorstep Return';
    }
  }

  bool get isInTransitToVendor => status == 'in_transit_back_to_vendor' || status == 'pending_return_to_vendor';
  bool get isReturnedToVendor => status == 'returned_to_vendor';

  factory ReturnCaseModel.fromJson(Map<String, dynamic> json) {
    return ReturnCaseModel(
      id: json['id'] as int? ?? 0,
      caseNumber: json['case_number'] as String? ?? '#RET-${json['id']}',
      orderId: json['order_id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? 'Order #${json['order_id']}',
      shopName: json['shop_name'] as String? ?? 'Merchant Shop',
      shopAddress: json['shop_address'] as String? ?? 'Vendor Address',
      shopPhone: json['shop_phone'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? 'Customer',
      customerPhone: json['customer_phone'] as String? ?? '',
      rejectionCategory: json['rejection_category'] as String? ?? 'vendor_issue',
      status: json['status'] as String? ?? 'in_transit_back_to_vendor',
      doorstepPhotoPath: json['doorstep_photo_path'] as String?,
      totalRefundableAmount: json['total_refundable_amount']?.toString() ?? '0.00',
      itemsSummary: json['items_summary'] as String? ?? 'Returned item(s)',
      timestamp: json['created_at']?.toString() ?? 'Recent',
    );
  }
}
