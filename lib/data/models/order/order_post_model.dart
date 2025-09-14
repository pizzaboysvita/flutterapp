// order_model.dart
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

  Map<String, dynamic> toJson() => {
    "dish_id": dishId,
    "name": name,
    "price": price,
    "quantity": quantity,
  };
}

class OrderDetail {
  final int dishId;
  final String dishNote;
  final int quantity;
  final double price;
  final String? base;
  final double? basePrice;

  OrderDetail({
    required this.dishId,
    required this.dishNote,
    required this.quantity,
    required this.price,
    this.base,
    this.basePrice,
  });

  Map<String, dynamic> toJson() => {
    "dish_id": dishId,
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
  final int? orderMasterId; // Optional field
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
  final List<OrderDetail> orderDetails;
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
    required this.orderDetails,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentAmount,
    this.isPosOrder = 1,
    required this.unitNumber,
    required this.gstPrice,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "total_price": totalPrice,
      "total_quantity": totalQuantity,
      "store_id": storeId,
      "order_type": orderType,
      "pickup_datetime": pickupDatetime,
      "delivery_address": deliveryAddress,
      "delivery_fees": deliveryFees,
      "delivery_datetime": deliveryDatetime,
      "order_notes": orderNotes,
      "order_status": orderStatus,
      "order_created_by": orderCreatedBy,
      "topping_details": toppingDetails.map((e) => e.toJson()).toList(),
      "ingredients_details": ingredientDetails.map((e) => e.toJson()).toList(),
      "order_details_json": orderDetails.map((e) => e.toJson()).toList(),
      "payment_method": paymentMethod,
      "payment_status": paymentStatus,
      "payment_amount": paymentAmount,
      "is_pos_order": isPosOrder,
      "unitnumber": unitNumber,
      "gst_price": gstPrice,
    };

    // Include order_master_id only if it's not null
    if (orderMasterId != null) {
      data["order_master_id"] = orderMasterId;
    }

    return data;
  }
}
  