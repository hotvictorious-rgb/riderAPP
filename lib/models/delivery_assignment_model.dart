class DeliveryAssignmentModel {
  final int id;
  final String orderNumber;
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String itemsSummary;
  final String dispatchCategory; // 'EXPRESS COURIER', 'STANDARD DISPATCH'
  final String orderStatus; // ready_for_pickup, out_for_delivery, delivered
  final String? pickupPin; // 6-digit courier PIN for vendor handover
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
    required this.itemsSummary,
    this.dispatchCategory = 'EXPRESS COURIER',
    required this.orderStatus,
    this.pickupPin,
    required this.timestamp,
  });

  factory DeliveryAssignmentModel.fromJson(Map<String, dynamic> json) {
    final shop = json['shop'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;

    return DeliveryAssignmentModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? json['id']?.toString() ?? 'VM-ORD-9081',
      shopName: shop?['name'] ?? 'Apex Retail Plaza (Hub #04)',
      shopAddress: shop?['address'] ?? 'Computer Village, Ikeja, Lagos',
      shopPhone: shop?['phone'] ?? '+234 801 234 5678',
      customerName: customer?['name'] ?? 'Chidi Okafor',
      customerPhone: customer?['phone'] ?? '+234 803 111 2233',
      deliveryAddress: json['delivery_address'] ?? '14 Admiralty Way, Lekki Phase 1, Lagos',
      itemsSummary: json['items_summary'] ?? '2 items (iPhone 14 Case, Fast Charger)',
      dispatchCategory: json['dispatch_category'] ?? 'EXPRESS COURIER',
      orderStatus: json['order_status'] ?? 'ready_for_pickup',
      pickupPin: json['pickup_verification_code'] ?? '482910',
      timestamp: json['created_at'] ?? 'Today, 11:30 AM',
    );
  }

  bool get isReadyForPickup => orderStatus == 'ready_for_pickup' || orderStatus == 'processing' || orderStatus == 'confirmed';
  bool get isOutForDelivery => orderStatus == 'out_for_delivery';
  bool get isDelivered => orderStatus == 'delivered';
}