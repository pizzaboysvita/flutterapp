import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/promocodes/promocode_bloc.dart';
import 'package:pizza_boys/core/bloc/promocodes/promocode_event.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_event.dart';

class RefreshCubit extends Cubit<bool> {
  RefreshCubit() : super(false);

  Future<void> refreshAll(BuildContext context) async {
    emit(true);
    debugPrint("🔄 Refresh Started");

    final storeId = await TokenStorage.getChosenStoreId();
    final storeName = await TokenStorage.getChosenLocation(); 
    debugPrint("🏪 Store Selected → ID: $storeId, Name: $storeName");

    if (storeId != null && storeName != null) {
      debugPrint("✅ Updating active store...");
      context.read<StoreWatcherCubit>().updateStore(storeId, storeName);
    } else {
      debugPrint("⚠️ No store found, skipping store update");
    }

    // === FAVORITES ===
    debugPrint("💛 Refresh Favorites...");
    context.read<FavoriteBloc>().add(FetchWishlistEvent(storeId: storeId));

    // === CART ===
    final isGuest = await TokenStorage.isGuest();
    debugPrint("👤 User Type → ${isGuest ? "GUEST" : "LOGGED-IN"}");

    if (isGuest) {
      debugPrint("🟨 Fetching cart for guest user...");
      context.read<CartGetBloc>().add(FetchCart(0));
    } else {
      final userIdStr = await TokenStorage.getUserId();
      final userId = int.tryParse(userIdStr ?? "0") ?? 0;
      debugPrint("🟩 Fetching cart for logged-in user → ID: $userId");
      context.read<CartGetBloc>().add(FetchCart(userId));
    }

    // === PROMO CODES ===
    final storeIdInt = int.tryParse(storeId ?? "0") ?? 0;
    debugPrint("🏷️ Fetching Promo Codes for Store ID → $storeIdInt");
    context.read<PromoBloc>().add(FetchPromos(storeIdInt));

    // === ORDERS ===
    if (!isGuest) {
      debugPrint("📦 Fetching Order History...");
      context.read<OrderGetBloc>().add(LoadOrdersEvent());
    } else {
      debugPrint("⛔ Skipping Order fetch (Guest user)");
    }

    debugPrint("✅ Refresh Completed Successfully");
    emit(false);
  }
}
