import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'ui/nav.dart';
import 'ui/notifications.dart';
import 'ui/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LocalNotifications().showNotification();
    return ThemeProvider(
      saveThemesOnChange: true,
      onInitCallback: (controller, previouslySavedThemeFuture) async {
        var savedTheme = await previouslySavedThemeFuture;
        if (savedTheme != null) {
          controller.setTheme(savedTheme);
          if (savedTheme == 'light_theme') {
            // change the theme to light for browsing page
            ThemeManager.setTheme(ThemeData.light());
          } else {
            ThemeManager.setTheme(ThemeData.dark());
          }
        }
      },
      themes: <AppTheme>[
        AppTheme(
          id: "light_theme",
          description: "Light Theme",
          data: ThemeData.light(),
        ),
        AppTheme(
          id: "dark_theme",
          description: "Dark Theme",
          data: ThemeData.dark(),
        ),
      ],
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) {
            return MaterialApp(
              title: 'Cinemate',
              theme: ThemeProvider.themeOf(themeContext).data,
              home: Nav(),
            );
          },
        ),
      ),
    );
  }
}
