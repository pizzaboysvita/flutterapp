
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pizza_boys/core/bloc/firebase/maintenance_bloc.dart';
import 'package:pizza_boys/core/bloc/firebase/maintenance_event.dart';
import 'package:pizza_boys/core/bloc/firebase/maintenance_state.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/helpers/firebase/cloud_messaging.dart';
import 'package:pizza_boys/core/helpers/firebase/remote_config.dart';
import 'package:pizza_boys/core/helpers/internet_helper/maintenance_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/navigation_error.dart';
import 'package:pizza_boys/core/helpers/notification_server.dart';
import 'package:pizza_boys/core/theme/default_theme.dart';
import 'package:pizza_boys/data/repositories/category/category_repo.dart';
import 'package:pizza_boys/data/repositories/dish/dish_repo.dart';
import 'package:pizza_boys/data/services/category/category_service.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';
import 'package:pizza_boys/features/home/bloc/integration/category/category_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_bloc.dart';
import 'package:pizza_boys/routes/app_pages.dart';
import 'package:pizza_boys/routes/app_routes.dart';

// ✅ Import ConnectivityWrapper
import 'package:pizza_boys/core/helpers/internet_helper/connectivity_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  await Firebase.initializeApp();
  await FBCloudMSG.init();

  Stripe.publishableKey =
      'pk_test_51SA6gy0hEBdd6GjAqeJGKPUG5dUz7tFjFT0mpLhoOqBO9aVB98RSuSqAZaplk9HP4mTj2gkxEC6CL9zrKgAchdLK00TI9cgEEd';

  // ✅ Set device orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final remoteConfigService = RemoteConfigService();
  await remoteConfigService.init();

  // ✅ Request location permission before running the app
  await _requestLocationPermission();

  // ✅ Initialize blocs
  final categoryBloc = CategoryBloc(CategoryRepository(CategoryService()));
  final dishBloc = DishBloc(DishRepository(DishService()));
  final maintenanceBloc = MaintenanceBloc(remoteConfigService);

  // ✅ Wrap PizzaBoysApp with ConnectivityWrapper at the TOP level
  runApp(
    OverlaySupport.global(
      child: BlocProviderHelper.getAllProviders(
        categoryBloc: categoryBloc,
        dishBloc: dishBloc,
        child: PizzaBoysApp(
          categoryBloc: categoryBloc,
          dishBloc: dishBloc,
          maintenanceBloc: maintenanceBloc,
        ),
      ),
    ),
  );
}

/// ✅ Function to request location permission
Future<void> _requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    final result = await Permission.location.request();
    if (result.isGranted) {
      print("✅ Location permission granted");
    } else {
      print("⚠️ Location permission denied");
    }
  } else {
    print("✅ Location permission already granted");
  }
}

class PizzaBoysApp extends StatelessWidget {
  final CategoryBloc categoryBloc;
  final DishBloc dishBloc;
  final MaintenanceBloc maintenanceBloc;

  const PizzaBoysApp({
    super.key,
    required this.categoryBloc,
    required this.dishBloc,
    required this.maintenanceBloc,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    // ✅ Debug print
    print("🌙 Current Material theme: ${isDarkMode ? "Dark" : "Light"}");
    return BlocBuilder<MaintenanceBloc, MaintenanceState>(
      bloc: maintenanceBloc,
      builder: (context, state) {
        if (state is MaintenanceOn) {
          return MaterialApp(
            home: MaintenanceScreen(
              message: state.message,
              onRetry: () {
                maintenanceBloc.add(CheckMaintenanceEvent());
              },
            ),
          );
        }
       return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return PlatformProvider(
              key: NavigatorService.navigatorKey,
              builder: (context) => PlatformApp(
                debugShowCheckedModeBanner: false,
                title: 'Pizza Boys',

                // ✅ Material side (Android)
                material: (_, __) => MaterialAppData(
                  theme: DefaultTheme.lightTheme, // Light mode
                  darkTheme: DefaultTheme.darkTheme, // Dark mode
                  themeMode: ThemeMode.system, // 🔥 Auto switch
                  builder: (context, child) {
                    return ConnectivityWrapper(
                      child: child ?? const SizedBox(),
                    );
                  },
                ),

                // ✅ Cupertino side (iOS)
                cupertino: (_, __) => CupertinoAppData(
                  theme: const CupertinoThemeData(
                    brightness: Brightness.light, // Light mode
                    scaffoldBackgroundColor: AppColors.scaffoldColorLight,
                  ),
                  builder: (context, child) {
                    return ConnectivityWrapper(
                      child: child ?? const SizedBox(),
                    );
                  },
                ),

                initialRoute: AppRoutes.splashScreen,
                onGenerateRoute: AppPages.generateRoutes,
              ),
            );
          },
        );
      },
    );
  }



}
