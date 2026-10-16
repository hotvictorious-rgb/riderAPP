import 'order_item_manifest_model.dart';

class DeliveryAssignmentModel {
  final int id;
  final String orderNumber;
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String destinationLga;
  final String itemsSummary;
  final int itemsCount;
  final List<OrderItemManifestModel> manifestItems;
  final String dispatchCategory;
  final String orderStatus;
  final String? pickupPin; // 6-digit courier PIN for vendor handover
  final bool hasRiderArrived; // whether courier has marked arrived at doorstep
  final String? riderArrivedAt;
  final bool isDeliveryLocked;
  final String timestamp;
  final String? pickupProofImage;
  final String? deliveryProofImage;
  final String? deliveryAttemptPhoto;
  final List<String> rejectionPhotos;

  DeliveryAssignmentModel({
    required this.id,
    required this.orderNumber,
    required this.shopName,
    required this.shopAddress,
    required this.shopPhone,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.destinationLga,
    required this.itemsSummary,
    required this.itemsCount,
    this.manifestItems = const [],
    this.dispatchCategory = 'EXPRESS COURIER',
    required this.orderStatus,
    this.pickupPin,
    this.hasRiderArrived = false,
    this.riderArrivedAt,
    this.isDeliveryLocked = false,
    required this.timestamp,
    this.pickupProofImage,
    this.deliveryProofImage,
    this.deliveryAttemptPhoto,
    this.rejectionPhotos = const [],
  });

  factory DeliveryAssignmentModel.fromJson(Map<String, dynamic> json) {
    final shop = json['shop'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    final destLga = json['destination_lga'] as Map<String, dynamic>? ?? json['destinationLga'] as Map<String, dynamic>?;

    // Build rich summary from eager loaded order_items
    String summary = 'Standard Package';
    int count = 1;
    final manifest = <OrderItemManifestModel>[];
    final itemsList = json['items'] as List<dynamic>?;
    if (itemsList != null && itemsList.isNotEmpty) {
      count = itemsList.length;
      final descriptions = itemsList.map((item) {
        manifest.add(OrderItemManifestModel.fromJson(item as Map<String, dynamic>));
        final name = item['product_name'] ?? 'Product';
        final qty = item['quantity'] ?? 1;
        return '$qty x $name';
      }).toList();
      summary = descriptions.join(', ');
    } else if (json['items_summary'] != null) {
      summary = json['items_summary'] as String;
    }

    final arrivedAt = json['rider_arrived_at'] as String?;
    final lockedUntil = json['delivery_locked_until'] as String?;
    bool locked = false;
    if (lockedUntil != null && lockedUntil.isNotEmpty) {
      try {
        final lockDate = DateTime.parse(lockedUntil);
        locked = DateTime.now().isBefore(lockDate);
      } catch (_) {}
    }

    final lgaName = destLga?['name'] as String? ?? '';
    final addressText = json['delivery_address'] as String? ?? (lgaName.isNotEmpty ? '$lgaName, Lagos' : 'Customer Address');

    final rejPhotos = <String>[];
    if (json['doorstep_rejection_photos'] is List) {
      for (final p in json['doorstep_rejection_photos']) {
        if (p != null) rejPhotos.add(p.toString());
      }
    }

    return DeliveryAssignmentModel(
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '#${json['id']}',
      shopName: shop?['name'] as String? ?? 'Merchant Shop',
      shopAddress: shop?['address'] as String? ?? 'Shop Address',
      shopPhone: shop?['phone'] as String? ?? '',
      customerName: customer?['name'] as String? ?? 'Customer',
      customerPhone: customer?['phone'] as String? ?? '',
      deliveryAddress: addressText,
      destinationLga: lgaName.isNotEmpty ? lgaName : 'Metropolitan Zone',
      itemsSummary: summary,
      itemsCount: count,
      manifestItems: manifest,
      dispatchCategory: json['dispatch_category'] as String? ?? 'EXPRESS COURIER',
      orderStatus: json['order_status'] as String? ?? 'ready_for_pickup',
      pickupPin: json['pickup_verification_code'] as String?,
      hasRiderArrived: arrivedAt != null,
      riderArrivedAt: arrivedAt,
      isDeliveryLocked: locked,
      timestamp: json['created_at'] != null ? _formatTimestamp(json['created_at'].toString()) : 'Recent',
      pickupProofImage: json['pickup_proof_image'] as String?,
      deliveryProofImage: json['proof_of_delivery_image'] as String?,
      deliveryAttemptPhoto: json['delivery_attempt_photo_path'] as String?,
      rejectionPhotos: rejPhotos,
    );
  }

  static String _formatTimestamp(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (_) {
      return raw;
    }
  }

  bool get isReadyForPickup => orderStatus == 'ready_for_pickup' || orderStatus == 'processing' || orderStatus == 'confirmed';
  bool get isOutForDelivery => orderStatus == 'out_for_delivery';
  bool get isDelivered => orderStatus == 'delivered';
  bool get hasAuditProofs => pickupProofImage != null || deliveryProofImage != null || deliveryAttemptPhoto != null || rejectionPhotos.isNotEmpty || manifestItems.any((m) => m.defectPhotoUrl != null);

  DeliveryAssignmentModel copyWith({
    int? id,
    String? orderNumber,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? destinationLga,
    String? itemsSummary,
    int? itemsCount,
    List<OrderItemManifestModel>? manifestItems,
    String? dispatchCategory,
    String? orderStatus,
    String? pickupPin,
    bool? hasRiderArrived,
    String? riderArrivedAt,
    bool? isDeliveryLocked,
    String? timestamp,
    String? pickupProofImage,
    String? deliveryProofImage,
    String? deliveryAttemptPhoto,
    List<String>? rejectionPhotos,
  }) {
    return DeliveryAssignmentModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      destinationLga: destinationLga ?? this.destinationLga,
      itemsSummary: itemsSummary ?? this.itemsSummary,
      itemsCount: itemsCount ?? this.itemsCount,
      manifestItems: manifestItems ?? this.manifestItems,
      dispatchCategory: dispatchCategory ?? this.dispatchCategory,
      orderStatus: orderStatus ?? this.orderStatus,
      pickupPin: pickupPin ?? this.pickupPin,
      hasRiderArrived: hasRiderArrived ?? this.hasRiderArrived,
      riderArrivedAt: riderArrivedAt ?? this.riderArrivedAt,
      isDeliveryLocked: isDeliveryLocked ?? this.isDeliveryLocked,
      timestamp: timestamp ?? this.timestamp,
      pickupProofImage: pickupProofImage ?? this.pickupProofImage,
      deliveryProofImage: deliveryProofImage ?? this.deliveryProofImage,
      deliveryAttemptPhoto: deliveryAttemptPhoto ?? this.deliveryAttemptPhoto,
      rejectionPhotos: rejectionPhotos ?? this.rejectionPhotos,
    );
  }
}
