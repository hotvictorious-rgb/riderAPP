class OrderItemManifestModel {
  final int orderItemId;
  final String productName;
  final int orderedQuantity;
  int acceptedQuantity;
  int rejectedQuantity;
  String? rejectionCategory; // 'vendor_issue', 'transit_damage', 'customer_change_of_mind'
  String? rejectionNotes;
  final String? defectPhotoUrl;

  OrderItemManifestModel({
    required this.orderItemId,
    required this.productName,
    required this.orderedQuantity,
    required this.acceptedQuantity,
    this.rejectedQuantity = 0,
    this.rejectionCategory,
    this.rejectionNotes,
    this.defectPhotoUrl,
  });

  factory OrderItemManifestModel.fromJson(Map<String, dynamic> json) {
    final qty = json['quantity'] as int? ?? 1;
    return OrderItemManifestModel(
      orderItemId: json['id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? 'Product Item',
      orderedQuantity: qty,
      acceptedQuantity: json['accepted_quantity'] as int? ?? qty,
      rejectedQuantity: json['rejected_quantity'] as int? ?? 0,
      rejectionCategory: json['rejection_category'] as String?,
      defectPhotoUrl: json['defect_photo_path'] as String?,
    );
  }

  Map<String, dynamic> toManifestJson() {
    return {
      'order_item_id': orderItemId,
      'accepted_quantity': acceptedQuantity,
      'rejected_quantity': rejectedQuantity,
      if (rejectedQuantity > 0 && rejectionCategory != null) 'rejection_category': rejectionCategory,
      if (rejectedQuantity > 0 && rejectionNotes != null && rejectionNotes!.isNotEmpty) 'rejection_notes': rejectionNotes,
    };
  }
}
