import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/core/storage/guset_local_storage.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_event.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_screen_tracker.dart';

class SessionManager {
  static Future<void> checkSession(BuildContext context) async {
    if (!context.mounted) return;

    if (ErrorScreenTracker.isShowing) {
      return;
    }

    // ✅ Check if first time app launch
    final isFirstLaunch = await TokenStorage.getIsFirstLaunch();
    if (isFirstLaunch) {
      await TokenStorage.setIsFirstLaunch(false); // mark first launch complete
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.landing);
      }
      return;
    }

    // ✅ Check if location is chosen
    final isLocationChosen = await TokenStorage.isLocationChosen();
    if (!isLocationChosen) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.chooseStoreLocation);
      }
      return;
    }

    // ✅ Check if user is logged in
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
      return;
    }

    // ✅ Everything is fine → go to Home

    if (context.mounted && !ErrorScreenTracker.isShowing) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

static Future<void> clearSession(BuildContext context) async {
  try {
    // 1️⃣ Preserve store info
    final storeId = await TokenStorage.getChosenStoreId();
    final storeName = await TokenStorage.loadSelectedStoreName();

    // 2️⃣ Clear user session but keep store info
    await TokenStorage.clearSession(); // your existing method (preserves store)

    // 3️⃣ Clear guest stored data

  // 👇 Clear cart & fav only of that store
  await LocalCartStorage.clearCart(storeId!);
  await LocalCartStorage.clearFavorites(storeId!);

    // 4️⃣ Reset blocs safely
    if (context.mounted) {
      context.read<CartGetBloc>().add(ClearCartEvent());
      context.read<FavoriteBloc>().add(ClearFavoritesEvent());
      context.read<OrderGetBloc>().add((ClearOrderGet()));


      // ✅ Reload store state (not updateStore)
      context.read<StoreWatcherCubit>().loadInitialStore();
    }

    // 5️⃣ Navigate clean
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );

    print("✅ Logout: session cleared but store preserved (storeId: $storeId, storeName: $storeName)");
  } catch (e) {
    print("❌ clearSession error: $e");
  }
}

}
