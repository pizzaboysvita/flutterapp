import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/data/repositories/auth/register_repo.dart';
import 'package:pizza_boys/data/repositories/cart/cart_repo.dart';
import 'package:pizza_boys/data/repositories/category/category_repo.dart';
import 'package:pizza_boys/data/repositories/dish/dish_repo.dart';
import 'package:pizza_boys/data/services/cart/cart_service.dart';
import 'package:pizza_boys/data/services/category/category_service.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';
import 'package:pizza_boys/features/auth/bloc/integration/register/register_bloc.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/checkout/checkout_cubit.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/ui/cart_ui_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/payment/payments_cubit.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_bloc.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/category/category_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/category/category_event.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/banner/banner_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/hero/animation_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/nav/nav_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_event.dart';
import 'package:pizza_boys/features/search/bloc/search_bloc.dart';
import 'package:pizza_boys/routes/app_pages.dart';
import 'package:pizza_boys/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final categoryBloc = CategoryBloc(CategoryRepository(CategoryService()))
    ..add(LoadCategories(userId: 1, type: 'web'));

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DishRepository>(
          create: (_) => DishRepository(DishService()),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (_) => CategoryRepository(CategoryService()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => CartUIBloc(),
          ), //cart ui view without api (remove)

          BlocProvider(create: (_) => RegisterBloc(AuthRepository())),
          BlocProvider(create: (_) => BikeAnimationBloc()),
          BlocProvider(create: (_) => BannerCarouselBloc()),
          BlocProvider(create: (_) => PizzaDetailsBloc()),
          BlocProvider(create: (_) => NavCubit()),
          BlocProvider(create: (_) => CheckoutCubit()),
          BlocProvider(create: (_) => PaymentCubit()),
          BlocProvider(create: (_) => SearchBloc()),
          BlocProvider(create: (_) => PsObscureBloc()),
          BlocProvider.value(value: categoryBloc),
          BlocProvider(
            create: (ctx) =>
                DishBloc(RepositoryProvider.of<DishRepository>(ctx)),
          ),
          BlocProvider(
            create: (_) => StoreSelectionBloc()..add(LoadStoresEvent()),
          ),
          BlocProvider(
            create: (_) =>
                CartBloc(cartRepository: CartRepository(CartService())),
          ),
          BlocProvider(
            create: (_) => CartGetBloc(CartRepository(CartService())),
          ),
          BlocProvider(create: (_) => FavoriteBloc()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, __) {
        return PlatformProvider(
          builder: (context) => PlatformApp(
            debugShowCheckedModeBanner: false,
            title: 'Pizza Boys',
            material: (_, __) => MaterialAppData(
              theme: ThemeData(
                scaffoldBackgroundColor: AppColors.scaffoldColor,
                appBarTheme: const AppBarTheme(
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  backgroundColor: AppColors.scaffoldColor,
                ),
              ),
            ),
            cupertino: (_, __) => CupertinoAppData(
              theme: const CupertinoThemeData(
                scaffoldBackgroundColor: AppColors.scaffoldColor,
              ),
            ),
            initialRoute: AppRoutes.splashScreen,
            onGenerateRoute: AppPages.generateRoutes,
          ),
        );
      },
    );
  }
}
