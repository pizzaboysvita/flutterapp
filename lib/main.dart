import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ Import permission handler
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/theme/default_theme.dart';
import 'package:pizza_boys/data/repositories/category/category_repo.dart';
import 'package:pizza_boys/data/repositories/dish/dish_repo.dart';
import 'package:pizza_boys/data/services/category/category_service.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';
import 'package:pizza_boys/features/home/bloc/integration/category/category_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/category/category_event.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_bloc.dart';
import 'package:pizza_boys/routes/app_pages.dart';
import 'package:pizza_boys/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Set device orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ✅ Request location permission before running the app
  await _requestLocationPermission();

  // ✅ Initialize blocs
  final categoryBloc = CategoryBloc(CategoryRepository(CategoryService()))
    ..add(LoadCategories(userId: 1, type: 'web'));
  final dishBloc = DishBloc(DishRepository(DishService()));

  // ✅ Run the app
  runApp(PizzaBoysApp(categoryBloc: categoryBloc, dishBloc: dishBloc));
}

/// ✅ Function to request location permission
Future<void> _requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    // Ask for permission
    final result = await Permission.location.request();
    if (result.isGranted) {
      print("✅ Location permission granted");
    } else {
      print("⚠️ Location permission denied");
      // Optionally: show a dialog to ask the user to enable permissions
    }
  } else {
    print("✅ Location permission already granted");
  }
}

class PizzaBoysApp extends StatelessWidget {
  final CategoryBloc categoryBloc;
  final DishBloc dishBloc;

  const PizzaBoysApp({
    super.key,
    required this.categoryBloc,
    required this.dishBloc,
  });

  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProviderHelper.getAllProviders(
          categoryBloc: categoryBloc,
          dishBloc: dishBloc,
          child: PlatformProvider(
            builder: (context) => PlatformApp(
              debugShowCheckedModeBanner: false,
              title: 'Pizza Boys',
              material: (_, __) =>
                  MaterialAppData(theme: DefaultTheme.defaultTheme),
              cupertino: (_, __) => CupertinoAppData(
                theme: const CupertinoThemeData(
                  scaffoldBackgroundColor: AppColors.scaffoldColor,
                ),
              ),
              initialRoute: AppRoutes.splashScreen,
              onGenerateRoute: AppPages.generateRoutes,
            ),
          ),
        );
      },
    );
  }
}
