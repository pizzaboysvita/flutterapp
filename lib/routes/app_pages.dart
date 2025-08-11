import 'package:flutter/material.dart';
import 'package:pizza_boys/features/auth/pages/login.dart';
import 'package:pizza_boys/features/auth/pages/register.dart';
import 'package:pizza_boys/features/cart/pages/cart_view.dart';
import 'package:pizza_boys/features/cart/pages/checkout.dart';
import 'package:pizza_boys/features/cart/pages/oder_details.dart';
import 'package:pizza_boys/features/cart/pages/payments.dart';
import 'package:pizza_boys/features/details/pages/category_pizza_details.dart';
import 'package:pizza_boys/features/details/pages/pizza_details.dart';
import 'package:pizza_boys/features/home/pages/home.dart';
import 'package:pizza_boys/features/onboard.dart/pages/choose_location.dart';
import 'package:pizza_boys/features/onboard.dart/pages/landing_page.dart';
import 'package:pizza_boys/features/onboard.dart/pages/splash_screen.dart';
import 'package:pizza_boys/features/profile/pages/profile.dart';
import 'package:pizza_boys/features/profile/pages/profile_edit.dart';
import 'package:pizza_boys/features/profile/pages/subpages/ai_chatbot.dart';
import 'package:pizza_boys/features/profile/pages/subpages/notifications.dart';
import 'package:pizza_boys/features/profile/pages/subpages/order_history.dart';
import 'package:pizza_boys/features/profile/pages/subpages/payment_methods.dart';
import 'package:pizza_boys/features/profile/pages/subpages/save_address.dart';
import 'package:pizza_boys/features/profile/pages/subpages/security_and_settings.dart';
import 'package:pizza_boys/features/profile/pages/subpages/support.dart';
import 'package:pizza_boys/features/search/pages/search_view.dart';
import 'package:pizza_boys/features/tracking/pages/order_tracking.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class AppPages {
  static Route<dynamic> generateRoutes(RouteSettings setting) {
    switch (setting.name) {
      case AppRoutes.pizzaDetails:
        return MaterialPageRoute(builder: (context) => PizzaDetailsView());
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (context) => Home(scrollController: ScrollController()),
        );
      case AppRoutes.cartView:
        return MaterialPageRoute(
          builder: (context) => CartView(scrollController: ScrollController()),
        );
      case AppRoutes.checkOut:
        return MaterialPageRoute(builder: (context) => Checkout());
      case AppRoutes.payments:
        return MaterialPageRoute(builder: (context) => PaymentPage());
      case AppRoutes.orderDetails:
        return MaterialPageRoute(builder: (context) => OrderDetails());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (context) => Register());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (context) => Login());
      case AppRoutes.landing:
        return MaterialPageRoute(builder: (context) => LandingPage());
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (context) => Profile(scrollController: ScrollController()),
        );
      case AppRoutes.profileEdit:
        return MaterialPageRoute(builder: (context) => ProfileEdit());
      case AppRoutes.searchView:
        return MaterialPageRoute(builder: (context) => SearchView());
      case AppRoutes.categoryPizzaDetails:
        final args = setting.arguments;
        return MaterialPageRoute(
          builder: (context) => CategoryPizzaDetails(arguments: args),
        );

      case AppRoutes.splashScreen:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case AppRoutes.orderTracking:
        return MaterialPageRoute(builder: (context) => OrderTracking());
      // Profile Sub Pages
      case AppRoutes.orderHistory:
        return MaterialPageRoute(builder: (context) => OrderHistoryView());
      case AppRoutes.saveAddress:
        return MaterialPageRoute(builder: (context) => SavedAddressesView());
      case AppRoutes.paymentMethods:
        return MaterialPageRoute(builder: (context) => PaymentMethodsView());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (context) => NotificationsView());
      case AppRoutes.support:
        return MaterialPageRoute(builder: (context) => SupportView());
      case AppRoutes.securityAndSetting:
        return MaterialPageRoute(builder: (context) => SecuritySettingsView());
      case AppRoutes.aiChatbot:
        return MaterialPageRoute(builder: (context) => AIChatBot());
      case AppRoutes.chooseStoreLocation:
        return MaterialPageRoute(builder: (context) => StoreSelectionPage());

      default:
        return MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: Text(
                  'No Route Found!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        );
    }
  }
}
