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
import 'package:pizza_boys/core/helpers/bloc_observer_helper.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/helpers/firebase/cloud_messaging.dart';
import 'package:pizza_boys/core/helpers/firebase/remote_config.dart';
import 'package:pizza_boys/core/helpers/internet_helper/connectivity_wrapper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/maintenance_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/navigation_error.dart';
import 'package:pizza_boys/core/helpers/notification_server.dart';
import 'package:pizza_boys/core/theme/default_theme.dart';
import 'package:pizza_boys/routes/app_pages.dart';
import 'package:pizza_boys/routes/app_routes.dart';

Future<void> main() async {
  Bloc.observer = AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  await Firebase.initializeApp();
  await FBCloudMSG.init();

  Stripe.publishableKey =
      'pk_test_51SA6gy0hEBdd6GjAqeJGKPUG5dUz7tFjFT0mpLhoOqBO9aVB98RSuSqAZaplk9HP4mTj2gkxEC6CL9zrKgAchdLK00TI9cgEEd';

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final remoteConfigService = RemoteConfigService();
  await remoteConfigService.init();

  await _requestLocationPermission();

  final maintenanceBloc = MaintenanceBloc(remoteConfigService);

  runApp(
    OverlaySupport.global(
      child: BlocProviderHelper.getAllProviders(
        child: PizzaBoysApp(
          maintenanceBloc: maintenanceBloc,
        ),
      ),
    ),
  );
}

Future<void> _requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    final result = await Permission.location.request();
    if (result.isGranted) {
      print('Location permission granted');
    } else if (result.isDenied) {
      print('Location permission denied');
    } else if (result.isPermanentlyDenied) {
      print('Location permission permanently denied, please enable it in settings');
      await openAppSettings();
    }
  }
}

class PizzaBoysApp extends StatelessWidget {
  final MaintenanceBloc maintenanceBloc;

  const PizzaBoysApp({super.key, required this.maintenanceBloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaintenanceBloc, MaintenanceState>(
      bloc: maintenanceBloc,
      builder: (context, state) {
        if (state is MaintenanceOn) {
          return MaterialApp(
            home: SafeArea(
              child: MaintenanceScreen(
                message: state.message,
                onRetry: () {
                  maintenanceBloc.add(CheckMaintenanceEvent());
                },
              ),
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

                // Material (Android)
                material: (_, __) => MaterialAppData(
                  theme: DefaultTheme.lightTheme,
                  darkTheme: DefaultTheme.darkTheme,
                  themeMode: ThemeMode.light,
                  builder: (context, child) {
                    return SafeArea(
                      top: true,
                      bottom: true,
                      child: ConnectivityWrapper(
                        child: child ?? const SizedBox(),
                      ),
                    );
                  },
                ),

                // Cupertino (iOS)
                cupertino: (_, __) => CupertinoAppData(
                  theme: const CupertinoThemeData(
                    brightness: Brightness.light,
                    scaffoldBackgroundColor: AppColors.scaffoldColorLight,
                  ),
                  builder: (context, child) {
                    return SafeArea(
                      top: true,
                      bottom: true,
                      child: ConnectivityWrapper(
                        child: child ?? const SizedBox(),
                      ),
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
