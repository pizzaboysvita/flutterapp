import 'dart:convert';

class ToppingDetail {
  final int dishId;
  final String name;
  final double price;
  final int quantity;

  ToppingDetail({
    required this.dishId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory ToppingDetail.fromJson(Map<String, dynamic> json) => ToppingDetail(
    dishId: json['dish_id'] ?? 0,
    name: json['name'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    quantity: json['quantity'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "dish_id": dishId,
    "name": name,
    "price": price,
    "quantity": quantity,
  };
}

class IngredientDetail {
  final int dishId;
  final String name;
  final double price;
  final int quantity;

  IngredientDetail({
    required this.dishId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) =>
      IngredientDetail(
        dishId: json['dish_id'] ?? 0,
        name: json['name'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "dish_id": dishId,
    "name": name,
    "price": price,
    "quantity": quantity,
  };
}

class OrderDetail {
  final int dishId;
  final String? dishName;
  final String dishNote;
  final int quantity;
  final double price;
  final String? base;
  final double? basePrice;

  OrderDetail({
    required this.dishId,
    this.dishName,
    required this.dishNote,
    required this.quantity,
    required this.price,
    this.base,
    this.basePrice,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
    dishId: json['dish_id'] ?? 0,
    dishName: json['dish_name'] ?? '',
    dishNote: json['dish_note'] ?? '',
    quantity: json['quantity'] ?? 0,
    price: (json['price'] ?? 0).toDouble(),
    base: json['base'],
    basePrice: json['base_price'] != null
        ? (json['base_price']).toDouble()
        : null,
  );

  Map<String, dynamic> toJson() => {
    "dish_id": dishId,
    "dish_name": dishName ?? 'Large Veg Masti Pizza',
    "dish_note": dishNote,
    "quantity": quantity,
    "price": price,
    if (base != null) "base": base,
    if (basePrice != null) "base_price": basePrice,
  };
}

class OrderModel {
  final double totalPrice;
  final int totalQuantity;
  final int? orderMasterId;
  final int storeId;
  final String orderType;
  final String pickupDatetime;
  final String? deliveryAddress;
  final double deliveryFees;
  final String? deliveryDatetime;
  final String orderNotes;
  final String orderStatus;
  final int orderCreatedBy;
  final List<ToppingDetail> toppingDetails;
  final List<IngredientDetail> ingredientDetails;
  final List<OrderDetail>? orderDetails;
  final String paymentMethod;
  final String paymentStatus;
  final double paymentAmount;
  final int isPosOrder;
  final String unitNumber;
  final double gstPrice;

  OrderModel({
    required this.totalPrice,
    required this.totalQuantity,
    this.orderMasterId,
    required this.storeId,
    required this.orderType,
    required this.pickupDatetime,
    this.deliveryAddress,
    this.deliveryFees = 0,
    this.deliveryDatetime,
    required this.orderNotes,
    required this.orderStatus,
    required this.orderCreatedBy,
    required this.toppingDetails,
    required this.ingredientDetails,
    this.orderDetails,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentAmount,
    this.isPosOrder = 1,
    required this.unitNumber,
    required this.gstPrice,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      totalQuantity: json['total_quantity'] ?? 0,
      orderMasterId: json['order_master_id'],
      storeId: json['store_id'] ?? 0,
      orderType: json['order_type']?.toString() ?? '',
      pickupDatetime: json['pickup_datetime'] ?? '',
      deliveryAddress: json['delivery_address'],
      deliveryFees: (json['delivery_fees'] ?? 0).toDouble(),
      deliveryDatetime: json['delivery_datetime'],
      orderNotes: json['order_notes'] ?? '',
      orderStatus: json['order_status'] ?? '',
      orderCreatedBy: json['order_created_by'] ?? 0,
      toppingDetails: parseToppingList(json['order_toppings']),
      ingredientDetails: parseIngredientList(json['order_ingredients']),
      orderDetails: parseOrderItemList(json['order_items']),
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentAmount: (json['payment_amount'] ?? 0).toDouble(),
      isPosOrder: json['is_pos_order'] ?? 1,
      unitNumber: json['unitnumber'] ?? '',
      gstPrice: (json['gst_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total_price": totalPrice,
      "total_quantity": totalQuantity,
      "store_id": storeId,
      "order_type": orderType,
      "pickup_datetime": pickupDatetime,
      "delivery_address": deliveryAddress ?? "",
      "delivery_fees": deliveryFees,
      "delivery_datetime": deliveryDatetime,
      "order_notes": orderNotes,
      "order_status": orderStatus,
      "order_created_by": orderCreatedBy,
      "topping_details": toppingDetails.map((e) => e.toJson()).toList(),
      "ingredients_details": ingredientDetails.map((e) => e.toJson()).toList(),
      "order_details_json": orderDetails?.map((e) => e.toJson()).toList() ?? [],
      "payment_method": paymentMethod,
      "payment_status": paymentStatus,
      "payment_amount": paymentAmount,
      "is_pos_order": isPosOrder,
      "unitnumber": unitNumber,
      "gst_price": gstPrice,
    };
  }

  // Parsing helpers
  static List<ToppingDetail> parseToppingList(dynamic jsonValue) {
    if (jsonValue == null) return [];
    try {
      final List parsed = jsonValue is String
          ? jsonDecode(jsonValue)
          : jsonValue;
      return parsed.map((e) => ToppingDetail.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static List<IngredientDetail> parseIngredientList(dynamic jsonValue) {
    if (jsonValue == null) return [];
    try {
      final List parsed = jsonValue is String
          ? jsonDecode(jsonValue)
          : jsonValue;
      return parsed.map((e) => IngredientDetail.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static List<OrderDetail> parseOrderItemList(dynamic jsonValue) {
    if (jsonValue == null) return [];
    try {
      final List parsed = jsonValue is String
          ? jsonDecode(jsonValue)
          : jsonValue;
      return parsed.map((e) => OrderDetail.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
