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
  final String dispatchCategory;
  final String orderStatus;
  final String? pickupPin; // 6-digit courier PIN for vendor handover
  final bool hasRiderArrived; // whether courier has marked arrived at doorstep
  final String? riderArrivedAt;
  final bool isDeliveryLocked;
  final String timestamp;

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
    this.dispatchCategory = 'EXPRESS COURIER',
    required this.orderStatus,
    this.pickupPin,
    this.hasRiderArrived = false,
    this.riderArrivedAt,
    this.isDeliveryLocked = false,
    required this.timestamp,
  });

  factory DeliveryAssignmentModel.fromJson(Map<String, dynamic> json) {
    final shop = json['shop'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    final destLga = json['destination_lga'] as Map<String, dynamic>? ?? json['destinationLga'] as Map<String, dynamic>?;

    // Build rich summary from eager loaded order_items
    String summary = 'Standard Package';
    int count = 1;
    final itemsList = json['items'] as List<dynamic>?;
    if (itemsList != null && itemsList.isNotEmpty) {
      count = itemsList.length;
      final descriptions = itemsList.map((item) {
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

    final lgaName = destLga?['name'] ?? 'Metropolitan Zone';
    final addressText = json['delivery_address'] ?? '$lgaName, Lagos';

    return DeliveryAssignmentModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? json['id']?.toString() ?? 'VM-ORD-9081',
      shopName: shop?['name'] ?? 'Apex Retail Plaza (Hub #04)',
      shopAddress: shop?['address'] ?? 'Computer Village, Ikeja, Lagos',
      shopPhone: shop?['phone'] ?? '+234 801 234 5678',
      customerName: customer?['name'] ?? 'Chidi Okafor',
      customerPhone: customer?['phone'] ?? '+234 803 111 2233',
      deliveryAddress: addressText,
      destinationLga: lgaName,
      itemsSummary: summary,
      itemsCount: count,
      dispatchCategory: json['dispatch_category'] ?? 'EXPRESS COURIER',
      orderStatus: json['order_status'] ?? 'ready_for_pickup',
      pickupPin: json['pickup_verification_code'] ?? '482910',
      hasRiderArrived: arrivedAt != null,
      riderArrivedAt: arrivedAt,
      isDeliveryLocked: locked,
      timestamp: json['created_at'] != null ? _formatTimestamp(json['created_at'].toString()) : 'Today, 11:30 AM',
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
    String? dispatchCategory,
    String? orderStatus,
    String? pickupPin,
    bool? hasRiderArrived,
    String? riderArrivedAt,
    bool? isDeliveryLocked,
    String? timestamp,
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
      dispatchCategory: dispatchCategory ?? this.dispatchCategory,
      orderStatus: orderStatus ?? this.orderStatus,
      pickupPin: pickupPin ?? this.pickupPin,
      hasRiderArrived: hasRiderArrived ?? this.hasRiderArrived,
      riderArrivedAt: riderArrivedAt ?? this.riderArrivedAt,
      isDeliveryLocked: isDeliveryLocked ?? this.isDeliveryLocked,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}