import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/internet_check_bloc.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/repositories/cart/cart_repo.dart';
import 'package:pizza_boys/data/repositories/category/category_repo.dart';

import 'package:pizza_boys/data/repositories/dish/dish_repo.dart';
import 'package:pizza_boys/data/repositories/order/order_repo.dart';
import 'package:pizza_boys/data/repositories/whishlist/whishlist_repo.dart';
import 'package:pizza_boys/data/services/cart/cart_service.dart';
import 'package:pizza_boys/data/services/category/category_service.dart';

import 'package:pizza_boys/data/services/dish/dish_service.dart';
import 'package:pizza_boys/data/services/order/order_service.dart';
import 'package:pizza_boys/data/services/whishlist/whishlist_service.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/checkout/checkout_cubit.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/order/post/order_post_bloc.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_bloc.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_event.dart';

import 'package:pizza_boys/features/home/bloc/integration/category/category_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/banner/banner_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/hero/animation_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/nav/nav_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_event.dart';
import 'package:pizza_boys/features/search/bloc/search_bloc.dart';
import 'package:pizza_boys/features/stripe/bloc/stripe_pay_bloc.dart';

class BlocProviderHelper {
  static Widget getAllProviders({required Widget child}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ConnectivityBloc()),
        BlocProvider(create: (_) => PizzaDetailsBloc()),
        BlocProvider(
          create: (_) =>
              CartBloc(cartRepository: CartRepository(CartService())),
        ),
        BlocProvider(create: (_) => CheckoutCubit()),
        BlocProvider(create: (_) => PaymentBloc()),
        BlocProvider(create: (_) => CartGetBloc(CartRepository(CartService()))),
        BlocProvider(
          create: (_) => OrderBloc(repository: OrderRepository(OrderService())),
        ),
        BlocProvider(
          create: (context) =>
              OrderGetBloc(OrderRepository(OrderService()))
                ..add(LoadOrdersEvent()),
        ),
        BlocProvider(create: (_) => SearchBloc()),
        BlocProvider(create: (_) => NavCubit()),
        BlocProvider(create: (_) => PsObscureBloc()),
        BlocProvider(create: (_) => BannerCarouselBloc()),
        BlocProvider(
          create: (_) => StoreSelectionBloc()..add(LoadStoresEvent()),
        ),
        BlocProvider(create: (_) => BikeAnimationBloc()),

        BlocProvider(create: (_) => StoreWatcherCubit()..loadInitialStore()),

        BlocProvider(
          create: (context) => FavoriteBloc(
            repository: FavoriteRepository(FavoriteService()),
            storeWatcherCubit: context.read<StoreWatcherCubit>(),
          )..add(FetchWishlistEvent()),
        ),

        // These depend on store watcher
        BlocProvider(
          create: (context) => CategoryBloc(
            CategoryRepository(CategoryService()),
            context.read<StoreWatcherCubit>(),
          ),
        ),
        BlocProvider(
          create: (context) => DishBloc(
            DishRepository(DishService()),
            context.read<StoreWatcherCubit>(),
          ),
        ),
      ],
      child: child,
    );
  }
}

class StoreWatcherCubit extends Cubit<String?> {
  StoreWatcherCubit() : super(null);

  /// Loads initial store ID from local storage
  void loadInitialStore() async {
    final storeId = await TokenStorage.getChosenStoreId();
    print("📦 [StoreWatcher] Initial store ID loaded: $storeId");
    emit(storeId);
  }

  /// Updates store ID when user selects a new location
  void updateStore(String newStoreId, String locationName) async {
    if (newStoreId != state) {
      print("🏪 [StoreWatcher] Store change detected!");
      print("   ├─ Previous store ID: ${state ?? 'none'}");
      print("   └─ New store ID: $newStoreId");

      await TokenStorage.saveChosenLocation(
        storeId: newStoreId,
        locationName: locationName,
      );

      emit(newStoreId);

      print("✅ [StoreWatcher] Store updated and emitted successfully");
    } else {
      print("ℹ️ [StoreWatcher] Same store selected ($newStoreId), no update.");
    }
  }
}
