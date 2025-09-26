import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/checkbox/login/login_checkbox_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/internet_check_bloc.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_bloc.dart';
import 'package:pizza_boys/data/repositories/auth/register_repo.dart';
import 'package:pizza_boys/data/repositories/cart/cart_repo.dart';
import 'package:pizza_boys/data/repositories/order/order_repo.dart';
import 'package:pizza_boys/data/repositories/whishlist/whishlist_repo.dart';
import 'package:pizza_boys/data/services/cart/cart_service.dart';
import 'package:pizza_boys/data/services/order/order_service.dart';
import 'package:pizza_boys/data/services/whishlist/whishlist_service.dart';
import 'package:pizza_boys/features/auth/bloc/integration/register/register_bloc.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/checkout/checkout_cubit.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/ui/cart_ui_bloc.dart';
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
  static Widget getAllProviders({
    required CategoryBloc categoryBloc,
    required DishBloc dishBloc,
    required Widget child,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ConnectivityBloc()),
        BlocProvider(create: (_) => CartUIBloc()),
        BlocProvider(create: (_) => LoadingButtonBloc()),
        BlocProvider(create: (_) => LoginCheckboxBloc()),
        BlocProvider(create: (_) => RegisterBloc(AuthRepository())),
        BlocProvider(create: (_) => BikeAnimationBloc()),
        BlocProvider(create: (_) => BannerCarouselBloc()),
        BlocProvider(create: (_) => PizzaDetailsBloc()),
        BlocProvider(create: (_) => NavCubit()),
        BlocProvider(create: (_) => CheckoutCubit()),
        BlocProvider(create: (_) => PaymentBloc()),
        BlocProvider(create: (_) => SearchBloc()),
        BlocProvider(create: (_) => PsObscureBloc()),
        BlocProvider.value(value: categoryBloc),
        BlocProvider.value(value: dishBloc),
        BlocProvider(
          create: (_) => StoreSelectionBloc()..add(LoadStoresEvent()),
        ),
        BlocProvider(
          create: (_) =>
              CartBloc(cartRepository: CartRepository(CartService())),
        ),
        BlocProvider(create: (_) => CartGetBloc(CartRepository(CartService()))),
        BlocProvider(
          create: (_) =>
              FavoriteBloc(repository: FavoriteRepository(FavoriteService()))
                ..add(FetchWishlistEvent()),
        ),
        BlocProvider(
          create: (_) => OrderBloc(repository: OrderRepository(OrderService())),
        ),

        BlocProvider(
          create: (context) =>
              OrderGetBloc(OrderRepository(OrderService()))
                ..add(LoadOrdersEvent()),
        ),
      ],
      child: child,
    );
  }
}
