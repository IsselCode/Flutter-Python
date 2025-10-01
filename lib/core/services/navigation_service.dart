import 'package:flutter/material.dart';

class NavigationService {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void navigateTo(Widget route) {
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => route,));
  }

  void navigateAndReplace(Widget route) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => route,),
      (route) => false,
    );
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }

}