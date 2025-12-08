import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:pizza_boys/core/constant/stripe_keys.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
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

import 'package:pizza_boys/firebase_options.dart';

import 'package:pizza_boys/routes/app_pages.dart';
import 'package:pizza_boys/routes/app_route_obs.dart';
import 'package:pizza_boys/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = StripeKeysUrl.publishableKey;
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
              home: StartupWrapperBody(),
            ),
          );
        },
      ),
    ),
  );
}

class StartupWrapperBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StartupWrapper();
  }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChecks();
    });
  }

  Future<void> _initChecks() async {
    try {
      final internet = await _checkInternet();
      setState(() => hasInternet = internet);
      if (!internet) return;

      final server = await _checkServer();
      setState(() => serverOk = server);

      if (!server) {
        ApiClient.isShowingServerError = false;
        ErrorScreenTracker.reset();

        final retryOptions = RequestOptions(
          baseUrl: ApiClient.dio.options.baseUrl,
          path: "healthCheck",
          method: "GET",
          headers: ApiClient.dio.options.headers,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ErrorNotifier.showErrorScreen(
            retryOptions,
            "Server temporarily unavailable. Please try again later.",
            ErrorScreenType.server,
            true,
          );
        });

        return;
      }

      await _initializeServices();
    } catch (e) {
      final retryOptions = RequestOptions(
        baseUrl: ApiClient.dio.options.baseUrl,
        path: "healthCheck",
        method: "GET",
        headers: ApiClient.dio.options.headers,
      );

      Future.delayed(const Duration(milliseconds: 400), () {
        ErrorNotifier.showErrorScreen(
          retryOptions,
          "Server temporarily unavailable. Please try again later.",
          ErrorScreenType.server,
          true,
        );
      });
    }
  }

  Future<void> _initializeServices() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      maintenanceBloc = MaintenanceBloc(RemoteConfigService());

      await NotificationService.initialize();
      await FBCloudMSG.init();
      await RemoteConfigService().init();
      await _requestLocationPermission();

      setState(() {});
    } catch (e) {
      print("Init error: $e");
    }
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _checkServer() async {
    try {
      final result = await ApiHealthChecker.checkServerHealth();
      return result;
    } catch (_) {
      return false;
    }
  }

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
    if (hasInternet == null || serverOk == null || maintenanceBloc == null) {
      return _loadingScreen();
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

    if (serverOk == false) {
      return _serverErrorScreen();
    }

    return PizzaBoysApp(maintenanceBloc: maintenanceBloc!);
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lotties/Pizza loading.json',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text("Loading, please wait..."),
          ],
        ),
      ),
    );
  }

  Widget _serverErrorScreen() {
    return Scaffold(
      body: Center(child: Text("Server unavailable. Try again later.")),
    );
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
          builder: (context, child) {
            return MaterialApp(
              navigatorKey: NavigatorService.navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Pizza Boys',
              theme: DefaultTheme.lightTheme,
              darkTheme: DefaultTheme.darkTheme,
              themeMode: ThemeMode.light,
              navigatorObservers: [routeLogger],
              builder: (context, child) =>
                  ConnectivityWrapper(child: child ?? const SizedBox()),
              initialRoute: AppRoutes.splashScreen,
              onGenerateRoute: AppPages.generateRoutes,
            );
          },
        );
      },
    );
  }
}
