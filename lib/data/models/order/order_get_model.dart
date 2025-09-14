import 'dart:convert';

class OrderGetModel {
  final int orderMasterId;
  final int storeId;
  final String totalPrice;
  final String? gstPrice;                 // Nullable field
  final int totalQuantity;
  final int orderType;
  final String pickupDatetime;
  final int isPosOrder;
  final String? deliveryAddress;         // Nullable field
  final String deliveryFees;
  final String? deliveryDatetime;        // Nullable field
  final String? unitNumber;
  final String? orderNotes;
  final String orderStatus;
  final String? deliveryNotes;
  final String? orderDue;
  final String? orderDueDatetime;
  final String orderCreatedDatetime;
  final int orderCreatedBy;
  final String? orderUpdatedOn;
  final String? orderUpdatedBy;
  final String paymentMethod;
  final String? email;
  final String? phoneNumber;
  final String? name;
  final List<Map<String, dynamic>> orderIngredients;
  final List<Map<String, dynamic>> orderToppings;

  OrderGetModel({
    required this.orderMasterId,
    required this.storeId,
    required this.totalPrice,
    this.gstPrice,
    required this.totalQuantity,
    required this.orderType,
    required this.pickupDatetime,
    required this.isPosOrder,
    this.deliveryAddress,
    required this.deliveryFees,
    this.deliveryDatetime,
    this.unitNumber,
    this.orderNotes,
    required this.orderStatus,
    this.deliveryNotes,
    this.orderDue,
    this.orderDueDatetime,
    required this.orderCreatedDatetime,
    required this.orderCreatedBy,
    this.orderUpdatedOn,
    this.orderUpdatedBy,
    required this.paymentMethod,
    this.email,
    this.phoneNumber,
    this.name,
    required this.orderIngredients,
    required this.orderToppings,
  });

  factory OrderGetModel.fromJson(Map<String, dynamic> json) {
    return OrderGetModel(
      orderMasterId: json['order_master_id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      totalPrice: parseNullableString(json['total_price']) ?? "0.00",
      gstPrice: parseNullableString(json['gst_price']),
      totalQuantity: json['total_quantity'] ?? 0,
      orderType: json['order_type'] ?? 0,
      pickupDatetime: parseNullableString(json['pickup_datetime']) ?? "",
      isPosOrder: json['is_pos_order'] ?? 0,
      deliveryAddress: parseNullableString(json['delivery_address']),
      deliveryFees: parseNullableString(json['delivery_fees']) ?? "0.00",
      deliveryDatetime: parseNullableString(json['delivery_datetime']),
      unitNumber: parseNullableString(json['unitnumber']),
      orderNotes: parseNullableString(json['order_notes']),
      orderStatus: parseNullableString(json['order_status']) ?? "Unknown",
      deliveryNotes: parseNullableString(json['delivery_notes']),
      orderDue: parseNullableString(json['order_due']),
      orderDueDatetime: parseNullableString(json['order_due_datetime']),
      orderCreatedDatetime: parseNullableString(json['order_created_datetime']) ?? "",
      orderCreatedBy: json['order_created_by'] ?? 0,
      orderUpdatedOn: parseNullableString(json['order_updated_on']),
      orderUpdatedBy: parseNullableString(json['order_updated_by']),
      paymentMethod: parseNullableString(json['payment_method']) ?? "",
      email: parseNullableString(json['email']),
      phoneNumber: parseNullableString(json['phone_number']),
      name: parseNullableString(json['name']),
      orderIngredients: parseJsonList(json['order_ingredients']),
      orderToppings: parseJsonList(json['order_toppings']),
    );
  }

  static List<Map<String, dynamic>> parseJsonList(dynamic jsonValue) {
    if (jsonValue == null) return [];
    try {
      if (jsonValue is String) {
        final parsed = jsonDecode(jsonValue);
        if (parsed is List) {
          return List<Map<String, dynamic>>.from(parsed);
        }
      } else if (jsonValue is List) {
        return List<Map<String, dynamic>>.from(jsonValue);
      }
    } catch (e) {
      print("Error parsing JSON list: $e");
    }
    return [];
  }

  static String? parseNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}
