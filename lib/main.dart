import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/data/repositories/category/category_repo.dart';
import 'package:pizza_boys/data/repositories/dish/dish_repo.dart';
import 'package:pizza_boys/data/services/category/category_service.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/checkout/checkout_cubit.dart';
import 'package:pizza_boys/features/cart/bloc/payment/payments_cubit.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_bloc.dart';
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
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BikeAnimationBloc()),
        BlocProvider(create: (_) => BannerCarouselBloc()),
        BlocProvider(create: (_) => PizzaDetailsBloc()),
        BlocProvider(create: (_) => NavCubit()),
        BlocProvider(create: (_) => CheckoutCubit()),
        BlocProvider(create: (_) => PaymentCubit()),
        BlocProvider(create: (_) => SearchBloc()),
        BlocProvider(create: (_) => PsObscureBloc()),
        BlocProvider.value(value: categoryBloc), // stays alive app-wide
        BlocProvider(create: (_) => DishBloc(DishRepository(DishService()))),
        BlocProvider(create: (_) => StoreSelectionBloc()..add(LoadStoresEvent())),
      ],
      child: const MyApp(), // this no longer rebuilds providers
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
