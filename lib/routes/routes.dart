import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:simple_calendar/routes/application.dart';

import 'handlers.dart';

// https://pub.dev/packages/fluro
class Routes {
  static String home = "/";
  static String settings = "/settings";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
      return;
    });
    router.define(home, handler: homeHandler);
    router.define(settings, handler: settingsHandler);
  }
}

Container renderBottomNavigationBar(
    BuildContext context, int currentIndex) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 0.2,
        ),
      ),
    ),
    child: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: '万年历',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '设置',
        ),
      ],
      selectedItemColor: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).colorScheme.background,
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Application.router.navigateTo(
              context,
              Routes.home,
              transition: TransitionType.none,
            );
            break;
          case 1:
            Application.router.navigateTo(
              context,
              Routes.settings,
              transition: TransitionType.none,
            );
            break;
        }
      },
    ),
  );
}
