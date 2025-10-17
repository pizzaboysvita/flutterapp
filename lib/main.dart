import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pizza_boys/core/bloc/firebase/maintenance_bloc.dart';
import 'package:pizza_boys/core/bloc/firebase/maintenance_event.dart';
import 'package:pizza_boys/core/bloc/firebase/maintenance_state.dart';
import 'package:pizza_boys/core/bloc/internet_check/internet_check_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/internet_check_state.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/helpers/bloc_observer_helper.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/helpers/firebase/cloud_messaging.dart';
import 'package:pizza_boys/core/helpers/firebase/remote_config.dart';
import 'package:pizza_boys/core/helpers/internet_helper/api_health_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/connectivity_wrapper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_notifier.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_screen_tracker.dart';
import 'package:pizza_boys/core/helpers/internet_helper/maintenance_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/navigation_error.dart';
import 'package:pizza_boys/core/helpers/internet_helper/network_issue_helper.dart';
import 'package:pizza_boys/core/helpers/notification_server.dart';
import 'package:pizza_boys/core/theme/default_theme.dart';
import 'package:pizza_boys/routes/app_pages.dart';
import 'package:pizza_boys/routes/app_route_obs.dart';
import 'package:pizza_boys/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    OverlaySupport.global(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) {
          return BlocProviderHelper.getAllProviders(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: StartupWrapper(),
            ),
          );
        },
      ),
    ),
  );
}

class StartupWrapper extends StatefulWidget {
  @override
  State<StartupWrapper> createState() => _StartupWrapperState();
}

class _StartupWrapperState extends State<StartupWrapper> {
  bool? hasInternet;
  bool? serverOk;
  MaintenanceBloc? maintenanceBloc;

  @override
  void initState() {
    super.initState();
    _initChecks();
  }

Future<void> _initChecks() async {
  try {
    // 1️⃣ Check Internet
    final internet = await _checkInternet();
    setState(() => hasInternet = internet);
    if (!internet) return;

    // 2️⃣ Check Server Health
    final server = await _checkServer();
    setState(() => serverOk = server);

    if (!server) {
      print("❌ Server not healthy — showing error screen.");

      // Safety reset before showing error
      ApiClient.isShowingServerError = false;
      ErrorScreenTracker.reset();

      // ✅ Fully valid RequestOptions for retry
      final retryOptions = RequestOptions(
        baseUrl: ApiClient.dio.options.baseUrl, // must be set
        path: "healthCheck",
        method: "GET",
        headers: ApiClient.dio.options.headers,
        connectTimeout: ApiClient.dio.options.connectTimeout,
        receiveTimeout: ApiClient.dio.options.receiveTimeout,
      );

      await ErrorNotifier.showErrorScreen(
        retryOptions,
        "Server temporarily unavailable. Please try again later.",
        ErrorScreenType.server,
        true,
      );

      return;
    }

    // 3️⃣ Initialize Firebase and other services
    await _initializeServices();
  } catch (e, stackTrace) {
    print("❌ _initChecks error: $e");
    print(stackTrace);

    // Optional: show a generic error screen in case of unexpected crash
    final retryOptions = RequestOptions(
      baseUrl: ApiClient.dio.options.baseUrl,
      path: "healthCheck",
      method: "GET",
      headers: ApiClient.dio.options.headers,
      connectTimeout: ApiClient.dio.options.connectTimeout,
      receiveTimeout: ApiClient.dio.options.receiveTimeout,
    );

    await ErrorNotifier.showErrorScreen(
      retryOptions,
      "An unexpected error occurred. Please try again.",
      ErrorScreenType.server,
      true,
    );
  }
}

  Future<void> _initializeServices() async {
    try {
      await Firebase.initializeApp(); // ✅ Firebase first
      maintenanceBloc = MaintenanceBloc(RemoteConfigService());

      await NotificationService.initialize();
      await FBCloudMSG.init();
      await RemoteConfigService().init();
      await _requestLocationPermission();

      Stripe.publishableKey =
          'pk_test_51SA6gy0hEBdd6GjAqeJGKPUG5dUz7tFjFT0mpLhoOqBO9aVB98RSuSqAZaplk9HP4mTj2gkxEC6CL9zrKgAchdLK00TI9cgEEd';

      setState(() {}); 
    } catch (e) {
      print("❌ Initialization error: $e");
    }
  }

  //  Check internet connectivity
  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Check server health
  Future<bool> _checkServer() async {
    try {
      return await ApiHealthChecker.checkServerHealth();
    } catch (_) {
      return false;
    }
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      final result = await Permission.location.request();
      if (result.isPermanentlyDenied) await openAppSettings();
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) async {
        if (state.hasInternet && hasInternet == false) {
          print("🌐 Internet restored! Rechecking server...");
          setState(() {
            hasInternet = null;
            serverOk = null;
            maintenanceBloc = null;
          });
          await _initChecks(); 
        }
      },
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (hasInternet == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lotties/Pizza loading.json',
                width: 150.w,
                height: 150.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),
              Text(
                "Loading, please wait...",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasInternet == false) {
      return NetworkIssueScreen(
        onRetry: () {
          setState(() {
            hasInternet = null;
            serverOk = null;
            maintenanceBloc = null;
          });
          _initChecks();
        },
      );
    }

    if (serverOk == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lotties/Pizza loading.json',
                width: 150.w,
                height: 150.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),
              Text(
                "Loading, please wait...",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (serverOk == false) {
      return const SizedBox.shrink();
    }

    if (maintenanceBloc == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lotties/Pizza loading.json',
                width: 150.w,
                height: 150.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),
              Text(
                "Loading, please wait...",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PizzaBoysApp(maintenanceBloc: maintenanceBloc!);
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
                onRetry: () => maintenanceBloc.add(CheckMaintenanceEvent()),
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
              builder: (context) => PlatformApp(
                navigatorKey: NavigatorService.navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Pizza Boys',

                material: (_, __) => MaterialAppData(
                  navigatorObservers: [routeLogger],
                  theme: DefaultTheme.lightTheme,
                  darkTheme: DefaultTheme.darkTheme,
                  themeMode: ThemeMode.light,
                  builder: (context, child) =>
                      ConnectivityWrapper(child: child ?? const SizedBox()),
                ),

                cupertino: (_, __) => CupertinoAppData(
                  theme: const CupertinoThemeData(
                    brightness: Brightness.light,
                    scaffoldBackgroundColor: AppColors.scaffoldColorLight,
                  ),
                  builder: (context, child) =>
                      ConnectivityWrapper(child: child ?? const SizedBox()),
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
