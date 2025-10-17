import 'package:flutter/material.dart';

class RouteLogger extends RouteObserver<PageRoute<dynamic>> {
  void _sendScreenView(PageRoute<dynamic> route) {
    final routeName = route.settings.name ?? route.runtimeType.toString();
    print("📍 [Navigation] Current Route → $routeName");
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) _sendScreenView(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) _sendScreenView(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute) _sendScreenView(previousRoute);
  }
}

final RouteLogger routeLogger = RouteLogger();
