import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/level_select_screen.dart';
import 'theme/palette.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Palette.bg,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Palette.bg,
  ));
  runApp(const MemphismApp());
}

class MemphismApp extends StatelessWidget {
  const MemphismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memphism',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Palette.bg,
        colorScheme: const ColorScheme.dark(
          surface: Palette.bg,
          primary: Palette.pink,
          secondary: Palette.cyan,
        ),
      ),
      home: const LevelSelectScreen(),
    );
  }
}
